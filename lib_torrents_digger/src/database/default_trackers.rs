use crate::database::{database_config::ACTIVE_TRACKERS_LIST_KEY, settings_kvs::insert_update_kv};

pub fn set_trackers_list(index: &str) -> Result<usize, rusqlite::Error> {
    insert_update_kv(ACTIVE_TRACKERS_LIST_KEY, index)
}
