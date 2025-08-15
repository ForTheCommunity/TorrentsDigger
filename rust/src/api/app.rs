
pub async fn dig_torrent(torrent_name: String) {
    println!("[RUST] Searching Torrent : {}", torrent_name);
}

// pub fn dig_torrent(torrent_name: String) -> Result<Vec<Torrent>, String> {
//     println!("[RUST] Searching Torrent : {}", torrent_name);

//     let search_query = SearchInput::new(
//         torrent_name,
//         libscrapper::sources::nyaa_dot_si::NyaaFilter::NoFilter,
//         libscrapper::sources::nyaa_dot_si::NyaaCategories::Anime,
//         1,
//     );

//     match search_torrent(search_query) {
//         Ok(torrents) => Ok(torrents),
//         Err(error) => {
//             let error_message = format!("{}", error);
//             Err(error_message)
//         }
//     }
// }
