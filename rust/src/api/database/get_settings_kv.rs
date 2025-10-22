use lib_torrents_digger::database::{
    default_trackers::{get_active_trackers_list, set_trackers_list},
    settings_kvs::fetch_all_kv,
};
use std::collections::HashMap;

pub fn get_settings_kv() -> Result<HashMap<String, String>, String> {
    match fetch_all_kv() {
        Ok(s_kv_s) => Ok(s_kv_s),
        Err(e) => Err(e.to_string()),
    }
}

pub fn set_default_trackers_list(index: i8) -> Result<usize, String> {
    match set_trackers_list(&index.to_string()) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_active_default_trackers_list() -> Result<String, String> {
    match get_active_trackers_list() {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}
