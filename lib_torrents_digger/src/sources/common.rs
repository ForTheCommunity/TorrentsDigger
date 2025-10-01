pub fn extract_info_hash_from_magnet(magnet: &str) -> String {
    // removing magnet link prefix to get info hash start
    let info_hash_start = magnet.trim_start_matches("magnet:?xt=urn:btih:");

    // finding index for first '&' separator i.e for torrent display name and for trackers.
    match info_hash_start.find("&") {
        Some(info_hash_length) => info_hash_start[..info_hash_length].to_string(),
        // if magnet link have no display name & trackers
        None => info_hash_start[..info_hash_start.len()].to_string(),
    }
}
