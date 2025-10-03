use crate::database::database_config::get_a_database_connection;

pub fn fetch_settings_data() {}

pub fn fetch_proxy_data() -> Result<Vec<(i32, String)>, rusqlite::Error> {
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
