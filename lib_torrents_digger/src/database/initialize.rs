use anyhow::Result;
use rusqlite::{Connection, params};
use std::{fs::create_dir_all, path::PathBuf, sync::MutexGuard};

use crate::{
    database::{
        database_config::{
            ACTIVE_TRACKERS_LIST_KEY, APP_ROOT_DIR, DATABASE_DIR, DATABASE_NAME, DATABASE_PATH,
            TRACKERS_DIR_PATH, TRACKERS_LISTS_DIR, get_a_database_connection,
        },
        settings_kvs::insert_update_kv,
    },
    trackers::DefaultTrackers,
};

// pub fn initialize_database(
//     torrents_digger_database_directory: String,
// ) -> Result<(), rusqlite::Error> {
//     let root_dir = PathBuf::from(torrents_digger_database_directory);
//     let app_dir = root_dir.join(APP_DIR_NAME);
//     let database_file_path = app_dir.join(DATABASE_NAME);
//     let trackers_path = app_dir.join(TRACKERS_LISTS_DIR);

//     // creating files & dirs
//     create_dir_all(app_dir).expect("Failed to create app directory");
//     create_dir_all(&trackers_path).expect("Failed to create trackers directory");

//     // set_platform_specific_root_dir_path(root_dir);
//     insert_update_kv(
//         APP_ROOT_DIR,
//         root_dir.to_string_lossy().into_owned().as_str(),
//     )?;

//     set_database_path(database_file_path);
//     set_trackers_dir_path(trackers_path);

//     // creating tables
//     create_tables()?;
//     // inserting configs.
//     insert_configs()?;
//     // insert default settings key values
//     insert_default_settings_kvs()?;

//     // downloading trackers lists
//     // need to use Anyhow crate later.....
//     DefaultTrackers::download_trackers_lists().unwrap();

//     Ok(())
// }

// this initialize database function is for temp use.,
// this will be / should be replaced/improved in future.
// this is not reliable......
pub fn initialize_database(torrents_digger_database_directory: String) -> Result<()> {
    let mut database_path: PathBuf = PathBuf::from(torrents_digger_database_directory);
    //  app root dir i,e database path..
    let root_dir_path = database_path.clone();

    let trackers_path = database_path.join(DATABASE_DIR).join(TRACKERS_LISTS_DIR);
    database_path.push(DATABASE_DIR.to_owned() + "/" + DATABASE_NAME);

    // creating database dir/file
    create_dir_all(database_path.parent().unwrap()).expect("Failed to create database directory");
    create_dir_all(&trackers_path).expect("Failed to create trackers directory");

    set_database_path(database_path);
    set_trackers_dir_path(trackers_path);

    // creating tables
    create_tables()?;
    // inserting configs.
    insert_configs()?;

    // insert default settings key values
    insert_default_settings_kvs()?;

    // saving app root dir..
    insert_update_kv(APP_ROOT_DIR, root_dir_path.to_str().unwrap())?;

    // downloading trackers lists
    // need to use Anyhow crate later.....
    DefaultTrackers::download_trackers_lists()?;

    Ok(())
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
        )
    ",
        params![],
    )?;

    // Supported Protocols Table
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

fn insert_default_settings_kvs() -> Result<(), rusqlite::Error> {
    let db_conn = get_a_database_connection();

    let default_key_value_pairs = vec![(ACTIVE_TRACKERS_LIST_KEY, "0")];

    for (key, value) in default_key_value_pairs {
        db_conn.execute(
            "
            INSERT OR IGNORE INTO settings_kvs (key,value) VALUES (?1,?2)
            ",
            params![key, value],
        )?;
    }
    Ok(())
}

fn set_database_path(database_path: PathBuf) {
    DATABASE_PATH
        .set(database_path)
        .expect("Database path can only be set once");
}

fn set_trackers_dir_path(trackers_dir_path: PathBuf) {
    TRACKERS_DIR_PATH
        .set(trackers_dir_path)
        .expect("Trackers dir path can only be set once");
}
