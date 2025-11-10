use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{self, ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet,
    sources::{QueryOptions, nyaa::NyaaSortings},
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
            sortings: true,
            filters: true,
            pagination: true,
        }
    }

    pub fn to_category(text_category: &str) -> Self {
        match text_category {
            "All Categories" => Self::AllCategories,
            "Art" => Self::Art,
            "Anime" => Self::Anime,
            "Art Doujinshi" => Self::ArtDoujinshi,
            "Art Games" => Self::ArtGames,
            "Art Manga" => Self::ArtManga,
            "Art Pictures" => Self::ArtPictures,
            "Real Life" => Self::RealLife,
            "Real Life Photobook And Pictures" => Self::RealLifePhotobookAndPictures,
            "Real Life Videos" => Self::RealLifeVideos,
            &_ => Self::AllCategories,
        }
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
        [
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
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        filter: &SukebeiNyaaFilter,
        category: &SukebeiNyaaCategories,
        sorting: &NyaaSortings,
        page_number: &i64,
    ) -> String {
        //https://sukebei.nyaa.si/?f=0&c=1_0&q=FC2-PPV-

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://sukebei.nyaa.si";
        let filter = format!("f={}", filter.filter_to_value());
        let query = format!("q={}", torrent_name);
        let category = format!("c={}", category.category_to_value());
        //  for now , sorting for High/Desc only.....
        let sorting = format!("s={}&o=desc", sorting.sorting_to_value());
        let page_number = format!("p={}", page_number);
        format!(
            "{}/?{}&{}&{}&{}&{}",
            root_url, filter, category, query, sorting, page_number
        )
    }

    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
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

        let pagination_selector = Selector::parse("ul.pagination li.active")
            .map_err(|e| anyhow!(format!("Error parsing pagination selector: {}", e)))?;

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

        let next_page_num: Option<i64> =
            if let Some(active_li) = document.select(&pagination_selector).next() {
                if let Some(anchor) = active_li.select(&anchor_tag_selector).next() {
                    let text = anchor.text().collect::<String>();
                    let current_page_str = text.split_whitespace().next().unwrap_or("1");
                    let current_page_num = current_page_str
                        .trim()
                        .parse::<i64>()
                        .map_err(|e| anyhow!("Error parsing page number: {}", e))?;
                    Some(current_page_num + 1)
                } else {
                    // Fallback in case there is no anchor tag
                    let current_page_num =
                        active_li.text().collect::<String>().trim().parse::<i64>()?;
                    Some(current_page_num + 1)
                }
            } else {
                // No active pagination element found, so no next page.
                None
            };

        // iterating over table rows.
        for table_row in table_body.select(&table_row_selector) {
            let table_data_vec: Vec<ElementRef> = table_row.select(&table_data_selector).collect();
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
            };

            all_torrents.push(torrent);
        }

        Ok((all_torrents, next_page_num))
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

pub enum SukebeiNyaaFilter {
    NoFilter,
    NoRemakes,
    TrustedOnly,
}

impl SukebeiNyaaFilter {
    pub fn filter_to_value(&self) -> i32 {
        match *self {
            Self::NoFilter => 0,
            Self::TrustedOnly => 1,
            Self::NoRemakes => 2,
        }
    }

    pub fn to_filter(filter_str: &str) -> Self {
        match filter_str {
            "No Filter" => Self::NoFilter,
            "Trusted Only" => Self::TrustedOnly,
            "No Remakes" => Self::NoRemakes,
            _ => Self::NoFilter,
        }
    }
    pub fn all_sukebei_nyaa_filters() -> Vec<String> {
        [Self::NoFilter, Self::TrustedOnly, Self::NoRemakes]
            .iter()
            .map(|filter| filter.to_string())
            .collect()
    }
}

impl fmt::Display for SukebeiNyaaFilter {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NoFilter => write!(f, "No Filter"),
            Self::TrustedOnly => write!(f, "Trusted Only"),
            Self::NoRemakes => write!(f, "No Remakes"),
        }
    }
}

#[derive(Debug)]
pub enum NyaaError {
    PageEnded,
    AlreadyAtStartPage,
    PaginationNotPossible,
}

impl std::error::Error for NyaaError {}

impl std::fmt::Display for NyaaError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NyaaError::AlreadyAtStartPage => {
                write!(f, "Already to Start Page , i.e page=1")
            }
            NyaaError::PageEnded => {
                write!(f, "Page Ended , No Page Available.")
            }
            NyaaError::PaginationNotPossible => {
                write!(f, "Page Doesn't Exists.")
            }
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
        let filter = SukebeiNyaaFilter::NoFilter;
        let category = SukebeiNyaaCategories::RealLifeVideos;
        let sorting = NyaaSortings::BySeeders;
        let page_number = 1;

        assert_eq!(
            "https://sukebei.nyaa.si/?f=0&c=2_2&q=FC2-PPV&s=seeders&o=desc&p=1".to_string(),
            SukebeiNyaaCategories::request_url_builder(
                torrent_query_name,
                &filter,
                &category,
                &sorting,
                &page_number
            )
        );
    }
}
