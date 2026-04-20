use anyhow::{Result, anyhow};
use include_dir::{Dir, include_dir};

use rusqlite_migration::Migrations;
use std::{fs::create_dir_all, path::PathBuf, sync::LazyLock};

use crate::{
    database::{
        database_config::{
            DATABASE_NAME, HYDRATION_DIR, PLATFORM_SPECIFIC_DIR, TRACKERS_DIR_PATH,
            TRACKERS_LISTS_DIR, get_a_database_connection, init_database_pool,
        },
        settings_kvs::insert_update_kv,
    },
    trackers::DefaultTrackers,
};

static MIGRATIONS_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/src/database/migrations");

static MIGRATIONS: LazyLock<Migrations<'static>> =
    LazyLock::new(|| Migrations::from_directory(&MIGRATIONS_DIR).unwrap());

pub fn initialize_database(platform_specific_home_dir: String) -> Result<()> {
    let platform_specific_data_dir = PathBuf::from(platform_specific_home_dir);
    let database_path = platform_specific_data_dir.join(DATABASE_NAME);
    let trackers_path = platform_specific_data_dir.join(TRACKERS_LISTS_DIR);
    let hydration_path = platform_specific_data_dir.join(HYDRATION_DIR);

    // creating App Config Dir
    create_dir_all(&platform_specific_data_dir)?;
    // creating Trackers dir
    create_dir_all(&trackers_path)?;
    // create Hydration dir (for flutter bloc)
    create_dir_all(&hydration_path)?;

    // initializing db pool..
    init_database_pool(&database_path);

    set_trackers_dir_path(trackers_path);

    let mut db_conn = get_a_database_connection();
    MIGRATIONS.to_latest(&mut db_conn)?;

    // saving app root dir..
    insert_update_kv(
        PLATFORM_SPECIFIC_DIR,
        platform_specific_data_dir
            .to_str()
            .ok_or_else(|| anyhow!("Unable to Insert/Update Platform Specific Home Dir"))?,
    )?;

    // downloading trackers lists
    DefaultTrackers::download_trackers_lists()?;

    Ok(())
}

fn set_trackers_dir_path(trackers_dir_path: PathBuf) {
    TRACKERS_DIR_PATH
        .set(trackers_dir_path)
        .expect("Trackers dir path can only be set once");
}
