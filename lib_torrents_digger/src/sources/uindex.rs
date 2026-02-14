use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
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
            filters: false,
            sortings: true,
            sorting_orders: true,
            pagination: false,
        }
    }

    const ALL_VARIANTS: &'static [UindexCategories] = &[
        Self::AllCategories,
        Self::Movies,
        Self::Tv,
        Self::Games,
        Self::Music,
        Self::Softwares,
        Self::XXX,
        Self::Anime,
        Self::Other,
    ];

    pub fn from_index(index: usize) -> Option<&'static UindexCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "0",
            Self::Movies => "1",
            Self::Tv => "2",
            Self::Games => "3",
            Self::Music => "4",
            Self::Softwares => "5",
            Self::XXX => "6",
            Self::Anime => "7",
            Self::Other => "8",
        }
    }

    pub fn all_categories() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &UindexCategories,
        sorting: &UindexSortings,
        sorting_order: &UindexSortingOrders,
    ) -> String {
        // https://uindex.org/search.php?search=batman&c=0&sort=seeders&order=DESC

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://uindex.org";
        let path = "search.php";
        let query = format!("search={}", torrent_name);
        let category = format!("c={}", category.category_to_value());
        let sorting = format!("sort={}", sorting.sorting_to_value());
        let sorting_order = format!("order={}", sorting_order.sorting_order_to_value());

        format!(
            "{}/{}?{}&{}&{}&{}",
            root_url, path, query, category, sorting, sorting_order
        )
    }

    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // Selectors
        let div_selector = Selector::parse(r#"div[id="results-area"]"#)
            .map_err(|e| anyhow!(format!("Error parsing div selector: {}", e)))?;

        let table_selector = Selector::parse("table")
            .map_err(|e| anyhow!(format!("Error parsing table selector: {}", e)))?;

        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!(format!("Error parsing table body selector: {}", e)))?;

        let table_row_selector = Selector::parse("tr")
            .map_err(|e| anyhow!(format!("Error parsing table row selector: {}", e)))?;

        let table_data_selector = Selector::parse("td")
            .map_err(|e| anyhow!(format!("Error parsing table data selector: {}", e)))?;

        let anchor_tag_selector = Selector::parse("a")
            .map_err(|e| anyhow!(format!("Error parsing anchor tag selector: {}", e)))?;

        let sub_div_selector = Selector::parse("div.sub")
            .map_err(|e| anyhow!(format!("Error parsing sub div selector: {}", e)))?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let div = document.select(&div_selector).next().unwrap();
        let table = div.select(&table_selector).next().unwrap();
        let table_body = table.select(&table_body_selector).next().unwrap();

        // checking if torrent is available or not.
        if table_body
            .text()
            .any(|error_text_response| error_text_response.trim() == "No results found.")
        {
            return Err(anyhow!("No torrents found with the specified name."));
        }

        let pagination = Pagination::new();

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
            let magnet = magnet_and_torrent_name_elem_vec
                .first()
                .and_then(|a| a.attr("href"))
                .unwrap_or("No Magnet Link Found..")
                .to_string();

            // extracting info hash from magnet
            let info_hash = extract_info_hash_from_magnet(&magnet).to_lowercase();

            // extracting torrent name
            let name = magnet_and_torrent_name_elem_vec
                .get(1)
                .map_or("Failed to Extract Torrent Name".to_string(), |a| {
                    a.text().collect::<String>()
                });

            let source_url = magnet_and_torrent_name_elem_vec
                .get(1)
                .and_then(|element| element.value().attr("href"))
                .map(|url| url.to_string())
                .map(|url| format!("{}{}", "https://uindex.org", url));

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
                source_url,
            });
        }

        Ok((all_torrents, pagination))
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
    const ALL_VARIANTS: &'static [UindexSortings] =
        &[Self::BySize, Self::BySeeders, Self::ByLeechers];

    pub fn from_index(index: usize) -> Option<&'static UindexSortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_to_value(&self) -> &str {
        match *self {
            Self::BySize => "size",
            Self::BySeeders => "seeders",
            Self::ByLeechers => "leechers",
        }
    }

    pub fn all_uindex_sortings() -> Vec<String> {
        Self::ALL_VARIANTS
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

pub enum UindexSortingOrders {
    Ascending,
    Descending,
}

impl UindexSortingOrders {
    const ALL_VARIANTS: &'static [UindexSortingOrders] = &[Self::Ascending, Self::Descending];

    pub fn from_index(index: usize) -> Option<&'static UindexSortingOrders> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_order_to_value(&self) -> &str {
        match *self {
            Self::Ascending => "ASC",
            Self::Descending => "DESC",
        }
    }

    pub fn all_uindex_sorting_orders() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for UindexSortingOrders {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Ascending => write!(f, "Ascending Order"),
            Self::Descending => write!(f, "Descending Order"),
        }
    }
}
