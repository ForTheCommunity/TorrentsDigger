use lib_torrents_digger::database::initialize::migrate_to_latest;

use crate::api::preludes::*;

pub fn initialize_torrents_digger_database(
    torrents_digger_database_directory: String,
) -> Result<(), String> {
    match initialize_database(torrents_digger_database_directory) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn migrate_database_to_latest() -> Result<(), String> {
    match migrate_to_latest() {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}
