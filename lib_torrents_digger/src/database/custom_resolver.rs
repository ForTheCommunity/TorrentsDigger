use crate::database::{
    database_config::CUSTOM_DNS_RESOLVER_KEY,
    settings_kvs::{check_key, fetch_kv, insert_update_kv},
};

pub fn get_active_custom_resolver() -> Result<Option<String>, rusqlite::Error> {
    if check_key(CUSTOM_DNS_RESOLVER_KEY)? {
        return Ok(fetch_kv(CUSTOM_DNS_RESOLVER_KEY)?);
    } else {
        insert_update_kv(CUSTOM_DNS_RESOLVER_KEY, "0")?;
        return Ok(fetch_kv(CUSTOM_DNS_RESOLVER_KEY)?);
    }
}

pub fn set_active_custom_resolver(index: &str) -> Result<usize, rusqlite::Error> {
    insert_update_kv(CUSTOM_DNS_RESOLVER_KEY, index)
}
