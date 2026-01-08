use rusqlite::params;

use crate::database::database_config::get_a_database_connection;

pub struct Proxy {
    pub id: i32,
    pub proxy_name: String,
    pub proxy_type: String,
    pub proxy_server_ip: String,
    pub proxy_server_port: String,
    pub proxy_username: Option<String>,
    pub proxy_password: Option<String>,
}

impl Proxy {
    pub fn save_proxy(&self) -> Result<usize, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let mut row_count_statement = db_conn.prepare("SELECT COUNT(*) FROM proxy_table")?;
        let row_count: i8 = row_count_statement.query_row([], |row| row.get(0))?;
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
                    self.proxy_name,
                    self.proxy_type,
                    self.proxy_server_ip,
                    self.proxy_server_port,
                    self.proxy_username,
                    self.proxy_password
                ],
            )?)
        } else {
            Err(rusqlite::Error::QueryReturnedMoreThanOneRow)
        }
    }

    pub fn fetch_supported_proxies() -> Vec<(i32, String)> {
        vec![
            (0, "NONE".into()),
            (1, "HTTP".into()),
            (2, "HTTPS".into()),
            (3, "SOCKS4".into()),
            (4, "SOCKS5".into()),
        ]
    }

    pub fn fetch_saved_proxy() -> Result<Option<Proxy>, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let mut sql_statement = db_conn.prepare(
        "
        SELECT id, proxy_name, proxy_type, proxy_server_ip, proxy_server_port, proxy_username, proxy_password FROM proxy_table
        LIMIT 1
        ",
    )?;

        let result = sql_statement.query_row([], |row| {
            Ok(Proxy {
                id: row.get(0)?,
                proxy_name: row.get(1)?,
                proxy_type: row.get(2)?,
                proxy_server_ip: row.get(3)?,
                proxy_server_port: row.get(4)?,
                proxy_username: row.get::<_, Option<String>>(5)?,
                proxy_password: row.get::<_, Option<String>>(6)?,
            })
        });

        match result {
            Ok(proxy) => Ok(Some(proxy)),
            Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
            Err(e) => Err(e),
        }
    }

    pub fn delete_proxy_by_id(proxy_id: i32) -> Result<usize, rusqlite::Error> {
        let db_conn = get_a_database_connection();

        let sql_statement = "DELETE FROM proxy_table WHERE id = ?1";

        let deleted_row_count = db_conn.execute(sql_statement, params![proxy_id])?;
        Ok(deleted_row_count)
    }
}
