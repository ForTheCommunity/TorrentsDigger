use anyhow::{Result, anyhow};
use include_dir::{Dir, include_dir};
use rusqlite::Connection;
use rusqlite_migration::Migrations;
use std::{
    fs::create_dir_all,
    path::PathBuf,
    sync::{LazyLock, MutexGuard},
};

use crate::{
    database::{
        database_config::{
            APP_DIR, DATABASE_NAME, DATABASE_PATH, HYDRATION_DIR, PLATFORM_SPECIFIC_DIR,
            TRACKERS_DIR_PATH, TRACKERS_LISTS_DIR, get_a_database_connection,
        },
        settings_kvs::insert_update_kv,
    },
    trackers::DefaultTrackers,
};

static MIGRATIONS_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/database/migrations");

static MIGRATIONS: LazyLock<Migrations<'static>> =
    LazyLock::new(|| Migrations::from_directory(&MIGRATIONS_DIR).unwrap());

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

    migrate();

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

fn migrate() {
    let mut db_conn: MutexGuard<'static, Connection> = get_a_database_connection();

    match MIGRATIONS.to_latest(&mut db_conn) {
        Ok(_) => println!("Mirgated Successfully...."),
        Err(e) => println!("Error -> {}", e.to_string()),
    }
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
