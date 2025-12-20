use crate::database::{
    database_config::ACTIVE_TRACKERS_LIST_KEY,
    settings_kvs::{fetch_kv, insert_update_kv},
};

pub fn set_trackers_list(index: &str) -> Result<usize, rusqlite::Error> {
    insert_update_kv(ACTIVE_TRACKERS_LIST_KEY, index)
}

pub fn get_active_trackers_list() -> Result<String, rusqlite::Error> {
    match fetch_kv(ACTIVE_TRACKERS_LIST_KEY) {
        Ok(Some(trackers)) => Ok(trackers),
        Ok(None) => Err(rusqlite::Error::QueryReturnedNoRows),
        Err(e) => Err(e),
    }
}
