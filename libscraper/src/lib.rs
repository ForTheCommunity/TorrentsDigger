use crate::sources::nyaa_dot_si::{NyaaCategories, NyaaFilter};

pub mod blocking_request;
pub mod sources;
pub mod torrent;

pub fn request_url_builder_nyaa(
    torrent_name: &str,
    filter: &NyaaFilter,
    category: &NyaaCategories,
    page_number: &i64,
) -> String {
    //https://nyaa.si/?f=0&c=1_0&q=naruto&s=seeders&o=desc&p=2

    let root_url = "https://nyaa.si";
    let filter = format!("f={}", filter.filter_to_value());
    let query = format!("q={}", torrent_name);
    let category = format!("c={}", category.category_to_value());
    let high_seeders_filter = "s=seeders&o=desc";
    let page_number = format!("p={}", page_number);
    format!(
        "{}/?{}&{}&{}&{}&{}",
        root_url, filter, category, query, high_seeders_filter, page_number
    )
}

// _______________________________________________________________________________________
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_nyaa() {
        let torrent_query_name = "naruto";
        let filter = NyaaFilter::NoFilter;
        let category = NyaaCategories::Anime;
        let page_number = 1;

        assert_eq!(
            "https://nyaa.si/?f=0&c=1_0&q=naruto&s=seeders&o=desc&p=1".to_string(),
            request_url_builder_nyaa(torrent_query_name, &filter, &category, &page_number)
        );
    }
}
