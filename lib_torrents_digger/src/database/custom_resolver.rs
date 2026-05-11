use crate::database::{
    database_config::CUSTOM_DNS_RESOLVER,
    settings_kvs::{check_key, fetch_kv, insert_update_kv},
};

pub fn get_active_custom_resolver() -> Result<Option<String>, rusqlite::Error> {
    if check_key(CUSTOM_DNS_RESOLVER)? {
        return Ok(fetch_kv(CUSTOM_DNS_RESOLVER)?);
    } else {
        insert_update_kv(CUSTOM_DNS_RESOLVER, "0")?;
        return Ok(fetch_kv(CUSTOM_DNS_RESOLVER)?);
    }
}
