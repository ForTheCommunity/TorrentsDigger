use rusqlite::{Connection, params};
use std::{fs::create_dir_all, path::PathBuf, sync::MutexGuard};

use crate::database::database_config::{
    DATABASE_DIR, DATABASE_NAME, DATABASE_PATH, get_a_database_connection,
};

pub fn initialize_database(torrents_digger_database_directory: String) {
    println!(
        "[RUST] DATABASE DIR : {}",
        torrents_digger_database_directory
    );

    let mut database_path: PathBuf = PathBuf::from(torrents_digger_database_directory);
    // println!("DATABASE PATH --->>> {:?}", database_path);

    database_path.push(DATABASE_DIR.to_owned() + "/" + DATABASE_NAME);

    // println!("DATABASE PATH --->>> {:?}", database_path);

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
    let result = db_conn.execute(
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
    println!("Bookmarked Torrent Table creation Status : {}", result);

    //   proxy BOOLEAN,
    // settings table / KeyValue Store.
    let result = db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS settings_kvs (
            key TEXT PRIMARY KEY,
            value TEXT
        )
        ",
        params![],
    )?;
    println!("settings table/kvs creation Status : {}", result);

    // Creating proxy table , this stores info about self
    let result = db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS proxy_table (
            id INTEGER PRIMARY KEY,
            proxy_type VARCHAR(255) NOT NULL,
            proxy_server_ip VARCHAR(255) NOT NULL,
            proxy_server_port VARCHAR(255) NOT NULL,
            proxy_username VARCHAR(255),
            proxy_password VARCHAR(255)
        )
    ",
        params![],
    )?;
    println!("proxy table creation Status : {}", result);

    // creating table to store supported protocols of proxy server..
    let result = db_conn.execute(
        "
        CREATE TABLE IF NOT EXISTS supported_proxy_protocols (
            id INTEGER PRIMARY KEY,
            protocol VARCHAR(50) NOT NULL UNIQUE
        )
    ",
        params![],
    )?;
    println!("proxy types table creation Status : {}", result);
    Ok(())
}

fn insert_configs() -> Result<(), rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let supported_protocols: [&str; 2] = ["SOCKS4", "SOCKS5"];

    for protocol in supported_protocols.iter() {
        let result = db_conn.execute(
            "
        INSERT INTO supported_proxy_protocols (protocol) VALUES (?1)
    ",
            params![protocol],
        )?;
        println!("Supported proxy protocols insertion status : {}", result);
    }
    Ok(())
}

fn set_database_path(database_path: PathBuf) {
    DATABASE_PATH
        .set(database_path)
        .expect("Database path can only be set once");
}
