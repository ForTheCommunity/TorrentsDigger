use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{self, ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet,
    sources::{
        Pagination, QueryOptions,
        nyaa::{NyaaFilter, NyaaSortingOrders, NyaaSortings},
    },
    torrent::Torrent,
};

// https://sukebei.nyaa.si/

// torrent categories
#[derive(Debug)]
pub enum SukebeiNyaaCategories {
    AllCategories,
    Art,
    Anime,
    ArtDoujinshi,
    ArtGames,
    ArtManga,
    ArtPictures,
    RealLife,
    RealLifePhotobookAndPictures,
    RealLifeVideos,
}

impl SukebeiNyaaCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: true,
            sortings: true,
            sorting_orders: true,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [SukebeiNyaaCategories] = &[
        Self::AllCategories,
        Self::Art,
        Self::Anime,
        Self::ArtDoujinshi,
        Self::ArtGames,
        Self::ArtManga,
        Self::ArtPictures,
        Self::RealLife,
        Self::RealLifePhotobookAndPictures,
        Self::RealLifeVideos,
    ];

    pub fn from_index(index: usize) -> Option<&'static SukebeiNyaaCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "0_0",
            Self::Art => "1_0",
            Self::Anime => "1_1",
            Self::ArtDoujinshi => "1_2",
            Self::ArtGames => "1_3",
            Self::ArtManga => "1_4",
            Self::ArtPictures => "1_5",
            Self::RealLife => "2_0",
            Self::RealLifePhotobookAndPictures => "2_1",
            Self::RealLifeVideos => "2_2",
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
        filter: &NyaaFilter,
        category: &SukebeiNyaaCategories,
        sorting: &NyaaSortings,
        sorting_order: &NyaaSortingOrders,
        page_number: &i64,
    ) -> String {
        //https://sukebei.nyaa.si/?f=0&c=1_0&q=FC2-PPV-

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://sukebei.nyaa.si";
        let filter = format!("f={}", filter.filter_to_value());
        let query = format!("q={}", torrent_name);
        let category = format!("c={}", category.category_to_value());
        let sorting = format!("s={}", sorting.sorting_to_value());
        let sorting_order = format!("o={}", sorting_order.sorting_order_to_value());
        let page_number = format!("p={}", page_number);
        format!(
            "{}/?{}&{}&{}&{}&{}&{}",
            root_url, filter, category, query, sorting, sorting_order, page_number
        )
    }

    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // selectors
        let div_selector = Selector::parse(r#"div[class="table-responsive"]"#)
            .map_err(|e| anyhow!(format!("Error parsing div selector: {}", e)))?;

        let table_selector = Selector::parse(r#"table"#)
            .map_err(|e| anyhow!(format!("Error parsing table selector: {}", e)))?;

        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!(format!("Error parsing table body selector: {}", e)))?;

        let table_row_selector = Selector::parse(r#"tr"#)
            .map_err(|e| anyhow!(format!("Error parsing table row selector: {}", e)))?;

        let table_data_selector = Selector::parse(r#"td"#)
            .map_err(|e| anyhow!(format!("Error parsing table data selector: {}", e)))?;

        let anchor_tag_selector = Selector::parse(r#"a"#)
            .map_err(|e| anyhow!(format!("Error parsing anchor tag selector: {}", e)))?;

        let active_li_selector = Selector::parse("li.active")
            .map_err(|e| anyhow!(format!("Error parsing active li selector: {}", e)))?;

        let prev_li_selector = Selector::parse("li.previous")
            .map_err(|e| anyhow!(format!("Error parsing previous li selector: {}", e)))?;

        let next_li_selector = Selector::parse("li.next")
            .map_err(|e| anyhow!(format!("Error parsing next li pagination selector: {}", e)))?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let div = document
            .select(&div_selector)
            .next()
            .ok_or_else(|| anyhow!("No torrents found with the specified name."))?;
        let table = div
            .select(&table_selector)
            .next()
            .ok_or_else(|| anyhow!("No Table Body Found......"))?;
        let table_body = table
            .select(&table_body_selector)
            .next()
            .ok_or_else(|| anyhow!("No Table Body Found......"))?;

        // iterating over table rows.
        for table_row in table_body.select(&table_row_selector) {
            let table_data_vec: Vec<ElementRef> = table_row.select(&table_data_selector).collect();

            // Ensure row has enough columns to avoid panics
            if table_data_vec.len() < 8 {
                continue;
            }

            let a_name: Vec<ElementRef> = table_data_vec[1].select(&anchor_tag_selector).collect();
            let torrent_data: Vec<ElementRef> =
                table_data_vec[2].select(&anchor_tag_selector).collect();

            // parsing

            let mut name_index = 0;
            if a_name.len() >= 2 {
                name_index = 1;
            }

            let name = a_name[name_index]
                .value()
                .attr("title")
                .unwrap_or("Name title attribute missing")
                .to_string();

            let source_url: Option<String> = a_name[name_index]
                .value()
                .attr("href")
                .map(|value| format!("{}{}", "https://sukebei.nyaa.si", value));

            let magnet = if torrent_data.len() > 1 {
                torrent_data[1].attr("href").unwrap_or_default().to_string()
            } else {
                String::from("Magnet link not available")
            };

            // extracting info hash from magnet
            let info_hash = extract_info_hash_from_magnet(&magnet).to_lowercase();

            let size = table_data_vec[3].inner_html().to_string();
            let date = table_data_vec[4].inner_html().to_string();
            let seeders = table_data_vec[5].inner_html().parse::<String>()?;
            let leechers = table_data_vec[6].inner_html().parse::<String>()?;
            let total_downloads = table_data_vec[7].inner_html().parse::<String>()?;

            let torrent = Torrent {
                info_hash,
                name,
                magnet,
                size,
                date,
                seeders,
                leechers,
                total_downloads,
                source_url,
            };

            all_torrents.push(torrent);
        }

        let mut pagination = Pagination {
            previous_page: None,
            current_page: None,
            next_page: None,
        };

        // Current Page
        if let Some(active_li) = document.select(&active_li_selector).next() {
            // extracting the number inside the <a>1</a>
            let text = active_li.text().collect::<String>();
            if let Ok(curr) = text.trim().parse::<i32>() {
                pagination.current_page = Some(curr);

                // for Previous Page
                if let Some(prev_li) = document.select(&prev_li_selector).next() {
                    let class = prev_li.value().attr("class").unwrap_or("");
                    // Only set if it doesn't contain disabled or unavailable
                    if !class.contains("disabled") && !class.contains("unavailable") {
                        pagination.previous_page = Some(curr - 1);
                    }
                }

                // for Next Page
                if let Some(next_li) = document.select(&next_li_selector).next() {
                    let class = next_li.value().attr("class").unwrap_or("");
                    if !class.contains("disabled") && !class.contains("unavailable") {
                        pagination.next_page = Some(curr + 1);
                    }
                }
            }
        }

        Ok((all_torrents, pagination))
    }
}

impl fmt::Display for SukebeiNyaaCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Art => write!(f, "Art"),
            Self::Anime => write!(f, "Anime"),
            Self::ArtDoujinshi => write!(f, "Art Doujinshi"),
            Self::ArtGames => write!(f, "Art Games"),
            Self::ArtManga => write!(f, "Art Manga"),
            Self::ArtPictures => write!(f, "Art Pictures"),
            Self::RealLife => write!(f, "Real Life"),
            Self::RealLifePhotobookAndPictures => write!(f, "Real Life Photobook And Pictures"),
            Self::RealLifeVideos => write!(f, "Real Life Videos"),
        }
    }
}

// _______________________________________________________________________________________
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_nyaa() {
        let torrent_query_name = "FC2-PPV";
        let filter = NyaaFilter::NoFilter;
        let category = SukebeiNyaaCategories::RealLifeVideos;
        let sorting = NyaaSortings::BySeeders;
        let sorting_order = NyaaSortingOrders::Descending;
        let page_number = 1;

        assert_eq!(
            "https://sukebei.nyaa.si/?f=0&c=2_2&q=FC2-PPV&s=seeders&o=desc&p=1".to_string(),
            SukebeiNyaaCategories::request_url_builder(
                torrent_query_name,
                &filter,
                &category,
                &sorting,
                &sorting_order,
                &page_number
            )
        );
    }
}
