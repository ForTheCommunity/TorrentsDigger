use libscrapper::{
    nyaa_dot_si::{NyaaCategories, NyaaFilter},
    request_url_builder_nyaa,
};

fn main() {
    let torrent_query_name = "naruto";
    let filter = NyaaFilter::NoFilter;
    let category = NyaaCategories::Anime;
    let _page = 1;

    let nyaa_req_url = request_url_builder_nyaa(torrent_query_name, &filter, &category, &_page);

    // TODO

    // sending request .... http client...
    //

    // Scraping
}
