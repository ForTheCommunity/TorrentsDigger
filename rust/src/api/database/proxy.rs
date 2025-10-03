use lib_torrents_digger::database::fetch::fetch_proxy_data;

pub fn get_proxy_details() -> Result<Vec<(i32, String)>, String> {
    match fetch_proxy_data() {
        Ok(pd) => Ok(pd),
        Err(e) => Err(e.to_string()),
    }
}
