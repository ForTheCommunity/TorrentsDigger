// use std::collections::HashMap;

use flutter_rust_bridge::frb;

#[frb(ignore)]
pub async fn search_torrent(torrent_name: String) {
    let url = "https://nyaa.si";
    let query_parameters = format!("?f=0&c=1_0&q={}&s=seeders&o=desc", torrent_name.trim());

    let _search_url = format!("{}/{}", url, query_parameters);

    println!("Search Query : {}", _search_url);

    let response = reqwest::get(_search_url).await.unwrap();
    let response_body = response.text().await.unwrap();
    println!("Response Body : {:?}", response_body);

    // parsing
}

#[frb(ignore)]
struct Torrents {
    torrent_name: String,
    torrent_size: String,
    total_seeders: String,
    total_leechers: String,
    magnet_link: String,
}
