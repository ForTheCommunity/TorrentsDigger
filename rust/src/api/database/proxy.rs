use lib_torrents_digger::database::proxy::Proxy;

use crate::api::internals::InternalProxy;

pub fn get_supported_proxy_details() -> Result<Vec<(i32, String)>, String> {
    match Proxy::fetch_supported_proxies() {
        Ok(pd) => Ok(pd),
        Err(e) => Err(e.to_string()),
    }
}

pub fn save_proxy_api(proxy_data: InternalProxy) -> Result<usize, String> {
    match Proxy::save_proxy(&Proxy {
        id: 1,
        proxy_name: proxy_data.proxy_name,
        proxy_type: proxy_data.proxy_type,
        proxy_server_ip: proxy_data.proxy_server_ip,
        proxy_server_port: proxy_data.proxy_server_port,
        proxy_username: proxy_data.proxy_username,
        proxy_password: proxy_data.proxy_password,
    }) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_saved_proxy() -> Result<Option<InternalProxy>, String> {
    match Proxy::fetch_saved_proxy() {
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
    match Proxy::delete_proxy_by_id(proxy_id) {
        Ok(result) => Ok(result),
        Err(e) => Err(e.to_string()),
    }
}
