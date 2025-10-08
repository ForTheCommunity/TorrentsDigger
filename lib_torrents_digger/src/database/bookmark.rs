use rusqlite::params;

use crate::{database::database_config::get_a_database_connection, torrent::Torrent};

pub fn create_a_bookmark(torrent: Torrent) -> Result<usize, rusqlite::Error> {
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
            total_downloads
        ) VALUES (?1,?2,?3,?4,?5,?6,?7,?8)",
        params![
            torrent.info_hash,
            torrent.name,
            torrent.magnet,
            torrent.size,
            torrent.date,
            torrent.seeders,
            torrent.leechers,
            torrent.total_downloads
        ],
    )
}

pub fn fetch_all_bookmarks() -> Result<Vec<Torrent>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
        SELECT * FROM bookmarked_torrents
    ",
    )?;

    let torrents_iter = sql_statement.query_map([], |a_row| {
        Ok(Torrent {
            info_hash: a_row.get(0)?,
            name: a_row.get(1)?,
            magnet: a_row.get(2)?,
            size: a_row.get(3)?,
            date: a_row.get(4)?,
            seeders: a_row.get(5)?,
            leechers: a_row.get(6)?,
            total_downloads: a_row.get(7)?,
        })
    })?;

    let all_bookmarked_torrents: Vec<Torrent> =
        torrents_iter.collect::<Result<Vec<Torrent>, _>>()?;

    // dbg!(&all_bookmarked_torrents);
    Ok(all_bookmarked_torrents)
}

pub fn check_bookmark(info_hash: String) -> Result<bool, rusqlite::Error> {
    let db_conn = get_a_database_connection();
    let mut sql_statement = db_conn.prepare(
        "
        SELECT * FROM bookmarked_torrents WHERE info_hash = ?1
    ",
    )?;

    let exists: i32 = sql_statement.query_row(params![info_hash], |row| row.get(0))?;
    if exists == 1 {
        Ok(true)
    } else if exists == 0 {
        Ok(false)
    } else {
        Err(rusqlite::Error::QueryReturnedNoRows)
    }
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
