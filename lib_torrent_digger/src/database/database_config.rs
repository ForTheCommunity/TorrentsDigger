use std::{
    path::PathBuf,
    sync::{Mutex, OnceLock},
};

use once_cell::sync::Lazy;
use rusqlite::Connection;

pub static DATABASE_PATH: OnceLock<PathBuf> = OnceLock::new();

static A_DATABASE_CONNECTION: Lazy<Mutex<Connection>> = Lazy::new(|| {
    let database_path = DATABASE_PATH
        .get()
        .expect("Database path must be set before using DB connection");
    let conn = Connection::open(database_path).expect("Failed to open database");

    Mutex::new(conn)
});

pub const DATABASE_DIR: &str = ".torrents_digger";
pub const DATABASE_NAME: &str = "torrents_digger.database";

pub fn get_a_database_connection() -> std::sync::MutexGuard<'static, Connection> {
    A_DATABASE_CONNECTION
        .lock()
        .expect("Failed to lock DB connection")
}
