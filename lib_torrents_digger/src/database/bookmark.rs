use std::collections::HashSet;

use rusqlite::{ErrorCode, params};

use crate::{database::database_config::get_a_database_connection, torrent::Torrent};

pub fn create_a_bookmark(torrent: Torrent, category_id: u8) -> Result<usize, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    db_conn.execute(
        "INSERT INTO bookmarked_torrents (
            info_hash,
            name,
            magnet,
            size,
            date,
            seeders,
            leechers,
            total_downloads,
            source_url,
            category_id
        ) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10)",
        params![
            torrent.info_hash,
            torrent.name,
            torrent.magnet,
            torrent.size,
            torrent.date,
            torrent.seeders,
            torrent.leechers,
            torrent.total_downloads,
            torrent.source_url,
            category_id
        ],
    )
}

pub fn fetch_bookmarks(
    category_id: u8,
    limit: u32,
    offset: u32,
) -> Result<Vec<Torrent>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
        SELECT * FROM bookmarked_torrents WHERE category_id = ?1
        LIMIT ?2 OFFSET ?3
    ",
    )?;

    let torrents_iter = sql_statement.query_map([category_id as u32, limit, offset], |a_row| {
        Ok(Torrent {
            info_hash: a_row.get(0)?,
            name: a_row.get(1)?,
            magnet: a_row.get(2)?,
            size: a_row.get(3)?,
            date: a_row.get(4)?,
            seeders: a_row.get(5)?,
            leechers: a_row.get(6)?,
            total_downloads: a_row.get(7)?,
            source_url: a_row.get(8)?,
        })
    })?;

    let all_bookmarked_torrents: Vec<Torrent> =
        torrents_iter.collect::<Result<Vec<Torrent>, _>>()?;

    Ok(all_bookmarked_torrents)
}

pub fn fetch_all_info_hashes() -> Result<HashSet<String>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
       SELECT info_hash FROM bookmarked_torrents
        ",
    )?;

    let info_hashes: HashSet<String> = sql_statement
        .query_map([], |row| row.get::<_, String>(0))?
        .collect::<Result<HashSet<_>, _>>()?;

    Ok(info_hashes)
}

pub fn delete_a_bookmark(info_hash: String) -> Result<bool, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let result = db_conn.execute(
        "
        DELETE FROM bookmarked_torrents WHERE info_hash = ?1
    ",
        params![info_hash],
    )?;

    if result == 1 { Ok(true) } else { Ok(false) }
}

pub fn search_bookmark(text: String) -> Result<Vec<Torrent>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
    SELECT * FROM bookmarked_torrents
    WHERE (name LIKE ?1 OR info_hash LIKE ?1) 
    ",
    )?;

    let search_pattern = format!("%{}%", text);

    let torrents_iter = sql_statement.query_map(params![search_pattern], |a_row| {
        Ok(Torrent {
            info_hash: a_row.get(0)?,
            name: a_row.get(1)?,
            magnet: a_row.get(2)?,
            size: a_row.get(3)?,
            date: a_row.get(4)?,
            seeders: a_row.get(5)?,
            leechers: a_row.get(6)?,
            total_downloads: a_row.get(7)?,
            source_url: a_row.get(8)?,
        })
    })?;

    let matched_torrents: Vec<Torrent> = torrents_iter.collect::<Result<Vec<Torrent>, _>>()?;

    Ok(matched_torrents)
}

#[derive(Clone)]
pub struct BookmarkCategory {
    pub id: u16,
    pub name: String,
}

impl BookmarkCategory {
    pub fn create(name: &str) -> Result<(), String> {
        let db_conn = get_a_database_connection();

        let result = db_conn.execute(
            "
            INSERT INTO bookmark_categories (name) VALUES (?1)",
            [name],
        );

        // errors handling
        if let Err(err) = result {
            return match err {
                rusqlite::Error::SqliteFailure(sqlite_err, _) => {
                    if sqlite_err.code == ErrorCode::ConstraintViolation {
                        Err(format!("Looks Like Category '{}' Already Exists", name))
                    } else {
                        Err(format!("Database error: {}", sqlite_err))
                    }
                }
                _ => Err(format!("An unexpected database error occurred: {}", err)),
            };
        };

        Ok(())
    }

    pub fn rename(
        category_id: u8,
        old_category_name: String,
        new_category_name: String,
    ) -> Result<(), rusqlite::Error> {
        let db_conn = get_a_database_connection();

        db_conn.execute(
            "
        UPDATE bookmark_categories SET name = ?1 WHERE id = ?2 AND name = ?3
        ",
            (new_category_name, category_id, old_category_name),
        )?;

        Ok(())
    }

    pub fn delete(category_id: u8) -> Result<(), rusqlite::Error> {
        let mut db_conn = get_a_database_connection();

        // starting a db transaction for safe deletion of
        // category & uncategorizing torrents associated with that category..
        let transaction = db_conn.transaction()?;

        // Uncategorizing Categorized torrents..
        transaction.execute(
            "DELETE FROM bookmarked_torrents WHERE category_id = ?1",
            [category_id],
        )?;

        // removing category
        transaction.execute(
            "DELETE FROM bookmark_categories WHERE id = ?1",
            [category_id],
        )?;

        // commiting transaction
        transaction.commit()?;

        Ok(())
    }

    pub fn get() -> Result<Vec<Self>, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let mut sql_statement = db_conn.prepare("SELECT id, name FROM bookmark_categories")?;

        let categories_iter = sql_statement.query_map([], |row| {
            Ok(BookmarkCategory {
                id: row.get(0)?,
                name: row.get(1)?,
            })
        })?;

        let mut categories = Vec::new();
        for category in categories_iter {
            categories.push(category?);
        }

        Ok(categories)
    }

    pub fn move_category(info_hash: String, category_id: u8) -> Result<(), rusqlite::Error> {
        let db_conn = get_a_database_connection();

        db_conn.execute(
            "
    UPDATE bookmarked_torrents SET category_id = ?1 WHERE info_hash = ?2
    ",
            (category_id, info_hash),
        )?;

        Ok(())
    }
}

pub struct BookmarksStats {
    pub categories_stats: Vec<CategoryStats>,
    pub global_stats: GlobalStats,
}

pub struct CategoryStats {
    // Category
    pub category: BookmarkCategory,
    // Category total torrents count.
    pub category_total_count: u16, // Max -> 65,535
    // Category torrents total size.
    pub category_total_size: String,
}

pub struct GlobalStats {
    // Total global torrents Count.
    pub total_torrents_count: u32, // Max -> 4,29,49,67,295
    // Total global torrents size.
    pub total_torrents_size: String,
}

impl BookmarksStats {
    pub fn get_stats() -> Result<Self, rusqlite::Error> {
        let categories = BookmarkCategory::get()?;

        let mut categories_stats: Vec<CategoryStats> = Vec::new();
        for a_category in categories {
            categories_stats.push(CategoryStats {
                category: a_category.clone(),
                category_total_count: Self::get_category_torrents_count(&a_category.id)?,
                category_total_size: Self::get_category_total_size(&a_category.id)?,
            });
        }

        let global_stats = GlobalStats {
            total_torrents_count: Self::get_total_torrents_count()?,
            total_torrents_size: Self::get_total_size()?,
        };

        Ok(Self {
            categories_stats,
            global_stats,
        })
    }

    fn get_category_torrents_count(category_id: &u16) -> Result<u16, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let count: u16 = db_conn.query_row(
            "
        SELECT COUNT(*) FROM bookmarked_torrents WHERE category_id = ?1
        ",
            params![category_id],
            |row| row.get(0),
        )?;

        Ok(count)
    }

    fn get_category_total_size(category_id: &u16) -> Result<String, rusqlite::Error> {
        let db_conn = get_a_database_connection();
        let sizes_vec: Vec<String> = {
            let mut sql_statement =
                db_conn.prepare("SELECT size FROM bookmarked_torrents WHERE category_id = ?1")?;

            let rows = sql_statement.query_map(params![category_id], |row| row.get(0))?;

            rows.filter_map(|r| r.ok()).collect()
        };

        let total_bytes = sizes_vec
            .iter()
            .filter_map(|s| Self::parse_size(s))
            .sum::<u64>();
        Ok(Self::format_size(total_bytes))
    }

    fn parse_size(size_str: &str) -> Option<u64> {
        let parts: Vec<&str> = size_str.trim().split_ascii_whitespace().collect();

        if parts.len() != 2 {
            return None;
        }

        let value: f64 = parts[0].parse().ok()?;
        let unit = parts[1].trim().to_uppercase();

        let multiplier: u64 = match unit.as_str() {
            "B" => 1,
            "KB" | "KIB" => 1_024,
            "MB" | "MIB" => 1_024 * 1_024,
            "GB" | "GIB" => 1_024 * 1_024 * 1_024,
            "TB" | "TIB" => 1_024 * 1_024 * 1_024 * 1_024,
            _ => return None,
        };
        Some((value * multiplier as f64) as u64)
    }

    fn format_size(bytes: u64) -> String {
        const KB: u64 = 1_024;
        const MB: u64 = 1_024 * KB;
        const GB: u64 = 1_024 * MB;
        const TB: u64 = 1_024 * GB;

        if bytes >= TB {
            format!("{:.2} TiB", bytes as f64 / TB as f64)
        } else if bytes >= GB {
            format!("{:.2} GiB", bytes as f64 / GB as f64)
        } else if bytes >= MB {
            format!("{:.2} MiB", bytes as f64 / MB as f64)
        } else if bytes >= KB {
            format!("{:.2} KiB", bytes as f64 / KB as f64)
        } else {
            format!("{} B", bytes)
        }
    }

    fn get_total_torrents_count() -> Result<u32, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let count: i64 =
            db_conn.query_row("SELECT COUNT(*) FROM bookmarked_torrents", [], |row| {
                row.get(0)
            })?;
        Ok(count as u32)
    }

    fn get_total_size() -> Result<String, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let sizes: Vec<String> = {
            let mut sql_statement = db_conn.prepare("SELECT size FROM bookmarked_torrents")?;
            let rows = sql_statement.query_map([], |row| row.get(0))?;
            rows.filter_map(|r| r.ok()).collect()
        };
        let total_bytes = sizes
            .iter()
            .filter_map(|s| Self::parse_size(s))
            .sum::<u64>();
        Ok(Self::format_size(total_bytes))
    }
}
