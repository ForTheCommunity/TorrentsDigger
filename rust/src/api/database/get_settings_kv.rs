use lib_torrents_digger::database::settings_kvs::fetch_all_kv;
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
