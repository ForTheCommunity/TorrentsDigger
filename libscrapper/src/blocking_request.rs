use crate::{
    nyaa_dot_si::{NyaaCategories, NyaaError, NyaaFilter},
    request_url_builder_nyaa,
};

pub fn search(search_input: SearchInput) {
    let request_url = request_url_builder_nyaa(
        &search_input.torrent_name,
        &search_input.filter,
        &search_input.category,
        &search_input.page_number,
    );

    // now , scrapping
}

pub struct SearchInput {
    torrent_name: String,
    page_number: i64,
    filter: NyaaFilter,
    category: NyaaCategories,
}

impl SearchInput {
    pub fn new(
        torrent_name: String,
        filter: NyaaFilter,
        category: NyaaCategories,
        page_number: i64,
    ) -> Result<Self, NyaaError> {
        Ok(SearchInput {
            torrent_name,
            filter,
            category,
            page_number,
        })
    }
}
