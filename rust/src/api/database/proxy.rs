use lib_torrents_digger::database::proxy::{
    delete_proxy_by_id, fetch_saved_proxy, fetch_supported_proxies, save_proxy,
};

use crate::api::internals::InternalProxy;

pub fn get_supported_proxy_details() -> Result<Vec<(i32, String)>, String> {
    match fetch_supported_proxies() {
        Ok(pd) => Ok(pd),
        Err(e) => Err(e.to_string()),
    }
}

pub fn save_proxy_api(
    proxy_name: String,
    proxy_type: String,
    proxy_server_ip: String,
    proxy_server_port: String,
    proxy_username: Option<String>,
    proxy_password: Option<String>,
) -> Result<usize, String> {
    match save_proxy(
        proxy_name,
        proxy_type,
        proxy_server_ip,
        proxy_server_port,
        proxy_username,
        proxy_password,
    ) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_saved_proxy() -> Result<Option<InternalProxy>, String> {
    match fetch_saved_proxy() {
        Ok(Some(proxy)) => Ok(Some(InternalProxy {
            id: proxy.id,
            proxy_name: proxy.proxy_name,
            proxy_type: proxy.proxy_type,
            proxy_server_ip: proxy.proxy_server_ip,
            proxy_server_port: proxy.proxy_server_port,
            proxy_username: proxy.proxy_username,
            proxy_password: proxy.proxy_password,
        })),
        Ok(None) => Ok(None),
        Err(e) => Err(e.to_string()),
    }
}

pub fn delete_proxy(proxy_id: i32) -> Result<usize, String> {
    match delete_proxy_by_id(proxy_id) {
        Ok(result) => Ok(result),
        Err(e) => Err(e.to_string()),
    }
}
