use rusqlite::{Connection, params};
use std::{fs::create_dir_all, path::PathBuf, sync::MutexGuard};

use crate::database::database_config::{
    DATABASE_DIR, DATABASE_NAME, DATABASE_PATH, get_a_database_connection,
};

pub fn initialize_database(torrents_digger_database_directory: String) {
    let mut database_path: PathBuf = PathBuf::from(torrents_digger_database_directory);

    database_path.push(DATABASE_DIR.to_owned() + "/" + DATABASE_NAME);

    // creating database dir/file
    create_dir_all(database_path.parent().unwrap()).expect("Failed to create database directory");

    set_database_path(database_path);

    // creating tables
    let _ = create_tables();
    // inserting configs.
    let _ = insert_configs();
}

fn create_tables() -> Result<(), rusqlite::Error> {
    let db_conn: MutexGuard<'static, Connection> = get_a_database_connection();

    //   proxy BOOLEAN,
    // Bookmarked Table
    db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS bookmarked_torrents (
            info_hash TEXT UNIQUE,
            name TEXT,
            magnet TEXT,
            size TEXT,
            date TEXT,
            seeders TEXT,
            leechers TEXT,
            total_downloads TEXT
        )
        ",
        params![],
    )?;

    // settings table / KeyValue Store.
    db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS settings_kvs (
            key TEXT PRIMARY KEY,
            value TEXT
        )
        ",
        params![],
    )?;

    // Creating proxy table , this stores info about self
    // only one row is allowded for now..
    // Todo :  multiple proxies support
    db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS proxy_table (
            id INTEGER PRIMARY KEY,
            proxy_name VARCHAR(255) NOT NULL,
            proxy_type VARCHAR(255) NOT NULL,
            proxy_server_ip VARCHAR(255) NOT NULL,
            proxy_server_port VARCHAR(255) NOT NULL,
            proxy_username VARCHAR(255),
            proxy_password VARCHAR(255)
            CHECK ( (SELECT COUNT(*) FROM proxy_table) <= 1 )
        )
    ",
        params![],
    )?;

    // Supported Protocols Table
    // Delete the entire table (structure and data)
    db_conn.execute(
        "DROP TABLE IF EXISTS supported_proxy_protocols",
        rusqlite::params![],
    )?;

    // creating table to store supported protocols of proxy server..
    db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS supported_proxy_protocols (
            id INTEGER PRIMARY KEY NOT NULL,
            protocol VARCHAR(50) NOT NULL UNIQUE
        )
    ",
        params![],
    )?;

    Ok(())
}

fn insert_configs() -> Result<(), rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let supported_protocols: [(i32, &str); 5] = [
        (0, "NONE"),
        (1, "HTTP"),
        (2, "HTTPS"),
        (3, "SOCKS4"),
        (4, "SOCKS5"),
    ];

    for (id, protocol) in supported_protocols.iter() {
        db_conn.execute(
            "
        INSERT OR IGNORE INTO supported_proxy_protocols (id,protocol) VALUES (?1,?2)
    ",
            params![id, protocol],
        )?;
    }
    Ok(())
}

fn set_database_path(database_path: PathBuf) {
    DATABASE_PATH
        .set(database_path)
        .expect("Database path can only be set once");
}
