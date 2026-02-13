use std::{path::PathBuf, sync::OnceLock};

use r2d2::{Pool, PooledConnection};
use r2d2_sqlite::SqliteConnectionManager;

pub const APP_DIR_NAME: &str = ".torrents_digger";
pub const TRACKERS_LISTS_DIR: &str = "trackers/";

pub const APP_DIR: &str = ".torrents_digger";
pub const DATABASE_NAME: &str = "torrents_digger.database";
pub const HYDRATION_DIR: &str = "hydration";

// Database Settings_KVS Keys
pub const ACTIVE_TRACKERS_LIST_KEY: &str = "active_trackers_list";
pub const PLATFORM_SPECIFIC_DIR: &str = "app_root_dir";

// DB Pool
pub type DBPool = Pool<SqliteConnectionManager>;
pub static DATABASE_POOL: OnceLock<DBPool> = OnceLock::new();

// pub static DATABASE_PATH: OnceLock<PathBuf> = OnceLock::new();
pub static TRACKERS_DIR_PATH: OnceLock<PathBuf> = OnceLock::new();

pub fn init_database_pool(database_path: &PathBuf) {
    // Connection Manager
    let conn_man = SqliteConnectionManager::file(database_path);

    let db_pool = Pool::builder()
        .max_size(5)
        .build(conn_man)
        .expect("Failed to create a Pool.");
    DATABASE_POOL
        .set(db_pool)
        .expect("Database Pool can be only be set once !!!");
}

pub fn get_a_database_connection() -> PooledConnection<SqliteConnectionManager> {
    DATABASE_POOL
        .get()
        .expect("Database Pool not initialized yet !!!")
        .get()
        .expect("Failed to get a Connection from Pool !!!")
}
