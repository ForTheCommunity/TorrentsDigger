use std::collections::HashMap;

use rusqlite::params;

use crate::database::database_config::get_a_database_connection;

pub fn insert_update_kv(key: &str, value: &str) -> Result<usize, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    db_conn.execute(
        "INSERT OR REPLACE INTO settings_kvs (key,value) VALUES (?1,?2)",
        params![key, value],
    )
}

pub fn fetch_kv(key: String) -> Result<String, rusqlite::Error> {
    let db_conn = get_a_database_connection();
    let mut sql_statement = db_conn.prepare(
        "
        SELECT value FROM settings_kvs WHERE key = ?1
    ",
    )?;
    let mut rows = sql_statement.query(params![key])?;
    let row = rows.next()?;
    match row {
        Some(r) => r.get(0),
        None => Err(rusqlite::Error::QueryReturnedNoRows),
    }
}

pub fn fetch_all_kv() -> Result<HashMap<String, String>, rusqlite::Error> {
    let db_conn = get_a_database_connection();
    let mut sql_statement = db_conn.prepare(
        "
        SELECT key, value FROM settings_kvs
    ",
    )?;
    let mut rows = sql_statement.query([])?;
    let mut hashmap = HashMap::new();
    while let Some(row) = rows.next()? {
        let key: String = row.get(0)?;
        let value: String = row.get(1)?;
        hashmap.insert(key, value);
    }
    Ok(hashmap)
}
