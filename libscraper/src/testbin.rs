use libscrapper::{
    blocking_request::{SearchInput, search_torrent},
    request_url_builder_nyaa,
    sources::nyaa_dot_si::{NyaaCategories, NyaaFilter},
};
use scraper::html;

fn main() {
    let torrent_query_name = "naruto";
    let filter = NyaaFilter::NoFilter;
    let category = NyaaCategories::Anime;
    let _page = 1;

    let nyaa_req_url = request_url_builder_nyaa(torrent_query_name, &filter, &category, &_page);

    // TODO

    // sending request .... http client...
    let search_input: SearchInput = SearchInput::new(
        "Naruto".to_string(),
        NyaaFilter::NoFilter,
        NyaaCategories::Anime,
        1,
    );
    let response = search_torrent(search_input);

    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.len());
        }
        Err(error) => {
            println!("Error Occurred : {:?}", error);
        }
    }
}
