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

pub fn fetch_bookmarks(category_id: u8) -> Result<Vec<Torrent>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
        SELECT * FROM bookmarked_torrents WHERE category_id = ?1
    ",
    )?;

    let torrents_iter = sql_statement.query_map([category_id], |a_row| {
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

pub struct BookmarkCategory {
    pub id: u8,
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
