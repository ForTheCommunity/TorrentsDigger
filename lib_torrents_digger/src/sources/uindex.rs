use core::fmt;
use std::error::Error;

use scraper::{ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet, sources::QueryOptions, torrent::Torrent, trackers::get_trackers,
};

#[derive(Debug)]
pub enum UindexCategories {
    AllCategories, // 'All Torrents' category on website
    Movies,
    Tv,
    Games,
    Music,
    Softwares, // 'Apps' category on website
    XXX,       // NSFW Category
    Anime,
    Other,
}

impl UindexCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            sortings: true,
            filters: false,
            pagination: false,
        }
    }

    pub fn to_category(text_category: &str) -> Self {
        match text_category {
            "All Categories" => Self::AllCategories,
            "Movies" => Self::Movies,
            "Tv" => Self::Tv,
            "Games" => Self::Games,
            "Music" => Self::Music,
            "Softwares" => Self::Softwares,
            "XXX" => Self::XXX,
            "Anime" => Self::Anime,
            "Other" => Self::Other,
            &_ => Self::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            Self::AllCategories => "0".to_string(),
            Self::Movies => "1".to_string(),
            Self::Tv => "2".to_string(),
            Self::Games => "3".to_string(),
            Self::Music => "4".to_string(),
            Self::Softwares => "5".to_string(),
            Self::XXX => "6".to_string(),
            Self::Anime => "7".to_string(),
            Self::Other => "8".to_string(),
        }
    }

    pub fn all_categories() -> Vec<String> {
        [
            Self::AllCategories,
            Self::Movies,
            Self::Tv,
            Self::Games,
            Self::Music,
            Self::Softwares,
            Self::XXX,
            Self::Anime,
            Self::Other,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &UindexCategories,
        sorting: &UindexSortings,
    ) -> String {
        // https://uindex.org/search.php?search=batman&c=0&sort=seeders&order=DESC

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_owned().into_owned();

        let root_url = "https://uindex.org";
        let path = "search.php";
        let query = format!("search={}", torrent_name);
        let category = format!("c={}", category.category_to_value());
        let sorting = format!("sort={}", sorting.sorting_to_value());
        // sorting order is hardcoded for now, i.e descending order.
        let order = "order=DESC";

        format!(
            "{}/{}?{}&{}&{}&{}",
            root_url, path, query, category, sorting, order
        )
    }

    // Scraping
    pub fn scrape_and_parse(
        mut response: Response<Body>,
    ) -> Result<(Vec<Torrent>, Option<i64>), Box<dyn Error>> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // Selectors
        let div_selector = Selector::parse(r#"div[id="results-area"]"#)?;
        let table_selector = Selector::parse("table")?;
        let table_body_selector = Selector::parse("tbody")?;
        let table_row_selector = Selector::parse("tr")?;
        let table_data_selector = Selector::parse("td")?;
        let anchor_tag_selector = Selector::parse("a")?;
        let sub_div_selector = Selector::parse("div.sub")?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let div = document.select(&div_selector).next().unwrap();
        let table = div.select(&table_selector).next().unwrap();
        let table_body = table.select(&table_body_selector).next().unwrap();

        // iterating over table rows.
        for table_row in table_body.select(&table_row_selector) {
            let table_row_data: Vec<ElementRef> = table_row.select(&table_data_selector).collect();

            if table_row_data.len() < 5 {
                // Skip rows that don't have the expected structure
                continue;
            }

            // magnet link and torrent name is in 2nd td.
            let magnet_and_torrent_name_elem_vec: Vec<ElementRef> =
                table_row_data[1].select(&anchor_tag_selector).collect();

            // extracting magnet link
            let mut magnet = magnet_and_torrent_name_elem_vec
                .first()
                .and_then(|a| a.attr("href"))
                .unwrap_or("No Magnet Link Found..")
                .to_string();

            // extracting info hash from magnet
            let info_hash = extract_info_hash_from_magnet(&magnet).to_lowercase();
            // adding more trackers
            magnet.push_str(get_trackers()?.as_str());

            // extracting torrent name
            let name = magnet_and_torrent_name_elem_vec
                .get(1)
                .map_or("Failed to Extract Torrent Name".to_string(), |a| {
                    a.text().collect::<String>()
                });

            let date_elem = table_row_data[1].select(&sub_div_selector).next();
            let date = date_elem.map_or("N/A".to_string(), |d| {
                d.text().collect::<String>().trim().to_string()
            });

            // extracting size.
            let size = table_row_data[2]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // extracting seeders
            let seeders = table_row_data[3]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // extracting leechers
            let leechers = table_row_data[4]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // total downloads
            // this source doesn't provide total downloads number.
            let total_downloads = "N/A".to_string();

            // saving to vector of torrents.
            all_torrents.push(Torrent {
                info_hash,
                name,
                magnet,
                size,
                date,
                seeders,
                leechers,
                total_downloads,
            });
        }

        Ok((all_torrents, None))
    }
}

impl fmt::Display for UindexCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Movies => write!(f, "Movies"),
            Self::Tv => write!(f, "Tv"),
            Self::Games => write!(f, "Games"),
            Self::Music => write!(f, "Music"),
            Self::Softwares => write!(f, "Softwares"),
            Self::XXX => write!(f, "XXX"),
            Self::Anime => write!(f, "Anime"),
            Self::Other => write!(f, "Other"),
        }
    }
}

pub enum UindexSortings {
    BySize,
    BySeeders,
    ByLeechers,
}

impl UindexSortings {
    pub fn to_sorting(sorting_str: &str) -> Self {
        match sorting_str {
            "By Size" => Self::BySize,
            "By Seeders" => Self::BySeeders,
            "By Leechers" => Self::ByLeechers,
            _ => Self::BySeeders,
        }
    }

    pub fn sorting_to_value(&self) -> String {
        match *self {
            Self::BySize => "size".to_string(),
            Self::BySeeders => "seeders".to_string(),
            Self::ByLeechers => "leechers".to_string(),
        }
    }

    pub fn all_uindex_sortings() -> Vec<String> {
        [Self::BySize, Self::BySeeders, Self::ByLeechers]
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for UindexSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::BySize => write!(f, "By Size"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}
