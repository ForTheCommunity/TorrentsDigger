use core::fmt;
use std::error::Error;

use anyhow::Result;
use scraper::{self, ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::torrent::Torrent;

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

    pub fn category_to_value(&self) -> String {
        match *self {
            Self::AllCategories => "0".to_string(),
            Self::Art => "1".to_string(),
            Self::Anime => "1_1".to_string(),
            Self::ArtDoujinshi => "1_2".to_string(),
            Self::ArtGames => "1_3".to_string(),
            Self::ArtManga => "1_4".to_string(),
            Self::ArtPictures => "1_5".to_string(),
            Self::RealLife => "2_0".to_string(),
            Self::RealLifePhotobookAndPictures => "2_1".to_string(),
            Self::RealLifeVideos => "2_2".to_string(),
        }
    }

    pub fn all_categories() -> Vec<Self> {
        vec![
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
    }

    pub fn request_url_builder(
        torrent_name: &str,
        filter: &SukebeiNyaaFilter,
        category: &SukebeiNyaaCategories,
        page_number: &i64,
    ) -> String {
        //https://sukebei.nyaa.si/?f=0&c=1_0&q=FC2-PPV-
        let torrent_name = torrent_name
            .split_whitespace()
            .collect::<Vec<&str>>()
            .join("+");

        let root_url = "https://sukebei.nyaa.si";
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
    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<Vec<Torrent>, Box<dyn Error>> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // selectors
        let div_selector = Selector::parse(r#"div[class="table-responsive"]"#)?;
        let table_selector = Selector::parse(r#"table"#)?;
        let table_body_selector = Selector::parse("tbody")?;
        let table_row_selector = Selector::parse(r#"tr"#)?;
        let table_data_selector = Selector::parse(r#"td"#)?;
        let anchor_tag_selector = Selector::parse(r#"a"#)?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let div = document.select(&div_selector).next().unwrap();
        let table = div.select(&table_selector).next().unwrap();
        let table_body = table.select(&table_body_selector).next().unwrap();

        // iterating over table rows.
        for table_row in table_body.select(&table_row_selector) {
            let table_data_vec: Vec<ElementRef> = table_row.select(&table_data_selector).collect();
            let a_name: Vec<ElementRef> = table_data_vec[1].select(&anchor_tag_selector).collect();
            let torrent_data: Vec<ElementRef> =
                table_data_vec[2].select(&anchor_tag_selector).collect();

            // parsing
            let id: i64 = a_name[0]
                .value()
                .attr("href")
                .unwrap()
                .chars()
                .filter(|c| c.is_numeric())
                .collect::<String>()
                .parse::<i64>()
                .unwrap();

            let mut name_index = 0;
            if a_name.len() >= 2 {
                name_index = 1;
            }

            let name = a_name[name_index]
                .value()
                .attr("title")
                .unwrap_or("Name title attribute missing")
                .to_string();

            let torrent_file = torrent_data[0]
                .attr("href")
                .unwrap_or("Torrent href attribute missing")
                .to_string();

            let magnet_link = if torrent_data.len() > 1 {
                torrent_data[1].attr("href").unwrap_or_default().to_string()
            } else {
                String::from("Magnet link not available")
            };

            let size = table_data_vec[3].inner_html().to_string();
            let date = table_data_vec[4].inner_html().to_string();
            let seeders = table_data_vec[5].inner_html().parse::<i64>()?;
            let leechers = table_data_vec[6].inner_html().parse::<i64>()?;
            let total_downloads = table_data_vec[7].inner_html().parse::<i64>()?;

            let torrent = Torrent {
                id,
                name,
                torrent_file,
                magnet_link,
                size,
                date,
                seeders,
                leechers,
                total_downloads,
            };

            all_torrents.push(torrent);
        }

        Ok(all_torrents)
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
            "NoFilter" => Self::NoFilter,
            "TrustedOnly" => Self::TrustedOnly,
            "NoRemakes" => Self::NoRemakes,
            _ => Self::NoFilter,
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
        let page_number = 1;

        assert_eq!(
            "https://sukebei.nyaa.si/?f=0&c=2_2&q=FC2-PPV&s=seeders&o=desc&p=1".to_string(),
            SukebeiNyaaCategories::request_url_builder(
                torrent_query_name,
                &filter,
                &category,
                &page_number
            )
        );
    }
}
