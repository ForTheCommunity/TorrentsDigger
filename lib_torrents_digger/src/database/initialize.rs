use anyhow::{Result, anyhow};
use rusqlite::{Connection, params};
use std::{fs::create_dir_all, path::PathBuf, sync::MutexGuard};

use crate::{
    database::{
        database_config::{
            ACTIVE_TRACKERS_LIST_KEY, APP_DIR, DATABASE_NAME, DATABASE_PATH, HYDRATION_DIR,
            PLATFORM_SPECIFIC_DIR, TRACKERS_DIR_PATH, TRACKERS_LISTS_DIR,
            get_a_database_connection,
        },
        settings_kvs::insert_update_kv,
    },
    trackers::DefaultTrackers,
};

pub fn initialize_database(platform_specific_home_dir: String) -> Result<()> {
    let platform_specific_home_dir = PathBuf::from(platform_specific_home_dir);
    let app_dir = platform_specific_home_dir.join(APP_DIR);
    let database_path = app_dir.join(DATABASE_NAME);
    let trackers_path = app_dir.join(TRACKERS_LISTS_DIR);
    let hydration_path = app_dir.join(HYDRATION_DIR);

    // creating App Config Dir
    create_dir_all(app_dir)?;
    // creating Trackers dir
    create_dir_all(&trackers_path)?;
    // create Hydration dir (for flutter bloc)
    create_dir_all(&hydration_path)?;

    set_database_path(database_path);
    set_trackers_dir_path(trackers_path);

    // creating tables
    create_tables()?;

    // insert default settings key values
    insert_default_settings_kvs()?;

    // saving app root dir..
    insert_update_kv(
        PLATFORM_SPECIFIC_DIR,
        platform_specific_home_dir
            .to_str()
            .ok_or_else(|| anyhow!("Unable to Insert/Update Platform Specific Home Dir"))?,
    )?;

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
