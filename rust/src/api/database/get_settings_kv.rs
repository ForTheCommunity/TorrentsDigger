use lib_torrents_digger::database::settings_kvs::{fetch_kv, insert_update_kv};

use crate::api::preludes::*;

pub fn get_a_settings_kv(key: String) -> Result<Option<String>, String> {
    match fetch_kv(&key) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn insert_or_update_kv(key: String, value: String) -> Result<String, String> {
    match insert_update_kv(&key, &value) {
        Ok(a) => Ok(a.to_string()),
        Err(e) => Err(e.to_string()),
    }
}

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
