use rusqlite::params;

use crate::database::database_config::get_a_database_connection;

pub fn save_proxy(
    proxy_name: String,
    proxy_type: String,
    proxy_server_ip: String,
    proxy_server_port: String,
    proxy_username: Option<String>,
    proxy_password: Option<String>,
) -> Result<usize, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut row_count_statement = db_conn.prepare("SELECT COUNT(*) FROM proxy_table")?;
    let row_count: usize = row_count_statement.query_row([], |row| row.get(0))?;
    if row_count == 0 {
        Ok(db_conn.execute(
            "INSERT INTO proxy_table (
            proxy_name,
            proxy_type,
            proxy_server_ip,
            proxy_server_port,
            proxy_username,
            proxy_password
        ) VALUES (?1,?2,?3,?4,?5,?6)
    ",
            params![
                proxy_name,
                proxy_type,
                proxy_server_ip,
                proxy_server_port,
                proxy_username,
                proxy_password
            ],
        )?)
    } else {
        // Create a custom SQLite error with a message
        Err(rusqlite::Error::QueryReturnedMoreThanOneRow)
    }
}

pub fn fetch_supported_proxies() -> Result<Vec<(i32, String)>, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
        SELECT id, protocol FROM supported_proxy_protocols
        ORDER BY id ASC
    ",
    )?;

    let proxies_iter = sql_statement.query_map([], |a_row| Ok((a_row.get(0)?, a_row.get(1)?)))?;

    let all_proxies: Vec<(i32, String)> =
        proxies_iter.collect::<Result<Vec<(i32, String)>, _>>()?;

    Ok(all_proxies)
}

pub fn fetch_saved_proxy() -> Result<(i32, String, String), rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let mut sql_statement = db_conn.prepare(
        "
            SELECT id, proxy_name, proxy_type FROM proxy_table
            LIMIT 1
        ",
    )?;

    // using query_row to fetch exactly one row..
    let saved_proxy: (i32, String, String) = sql_statement.query_row([], |a_row| {
        Ok((a_row.get(0)?, a_row.get(1)?, a_row.get(2)?))
    })?;

    Ok(saved_proxy)
}

pub fn delete_proxy_by_id(proxy_id: i32) -> Result<usize, rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let sql_statement = "DELETE FROM proxy_table WHERE id = ?1";

    let deleted_row_count = db_conn.execute(sql_statement, params![proxy_id])?;
    Ok(deleted_row_count)
}
