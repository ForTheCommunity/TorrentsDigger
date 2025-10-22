use lib_torrents_digger::database::{
    default_trackers::set_trackers_list, settings_kvs::fetch_all_kv,
};
use std::collections::HashMap;

pub fn get_settings_kv() -> HashMap<String, String> {
    match fetch_all_kv() {
        Ok(s_kv_s) => s_kv_s,
        Err(_e) => {
            // returning empty hashmap
            HashMap::new()
        }
    }
}

pub fn set_default_trackers_list(index: i8) -> Result<usize, String> {
    match set_trackers_list(&index.to_string()) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}
