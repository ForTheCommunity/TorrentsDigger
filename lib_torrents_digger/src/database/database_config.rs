use std::{
    path::PathBuf,
    sync::{Mutex, OnceLock},
};

use once_cell::sync::Lazy;
use rusqlite::Connection;

pub const APP_DIR_NAME: &str = ".torrents_digger";
pub const TRACKERS_LISTS_DIR: &str = "trackers/";

// Database Settings_KVS Keys
pub const ACTIVE_TRACKERS_LIST_KEY: &str = "active_trackers_list";
pub const PLATFORM_SPECIFIC_DIR: &str = "app_root_dir";

pub static DATABASE_PATH: OnceLock<PathBuf> = OnceLock::new();
pub static TRACKERS_DIR_PATH: OnceLock<PathBuf> = OnceLock::new();

static A_DATABASE_CONNECTION: Lazy<Mutex<Connection>> = Lazy::new(|| {
    let database_path = DATABASE_PATH
        .get()
        .expect("Database path must be set before using DB connection");
    let conn = Connection::open(database_path).expect("Failed to open database");

    Mutex::new(conn)
});

pub const APP_DIR: &str = ".torrents_digger";
pub const DATABASE_NAME: &str = "torrents_digger.database";
pub const HYDRATION_DIR: &str = "hydration";

pub fn get_a_database_connection() -> std::sync::MutexGuard<'static, Connection> {
    A_DATABASE_CONNECTION
        .lock()
        .expect("Failed to lock DB connection")
}
