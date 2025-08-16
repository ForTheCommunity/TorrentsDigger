use core::fmt;
use std::error::Error;

use anyhow::Result;
use reqwest::blocking::Response;
use scraper::{self, ElementRef, Html, Selector};

use crate::torrent::Torrent;

// torrent categories
#[derive(Debug)]
pub enum NyaaCategories {
    AllCategories,
    Anime,
    AnimeMusicVideo,
    AnimeEnglishTranslated,
    AnimeNonEnglishTranslated,
    AnimeRaw,
    Audio,
    AudioLossLess,
    AudioLossy,
    Literature,
    LiteratureEnglishTranslated,
    LiteratureNonEnglishTranslated,
    LiteratureRaw,
    LiveAction,
    LiveActionEnglishTranslated,
    LiveActionNonEnglishTranslated,
    LiveActionIdolPromotionalVideo,
    LiveActionRaw,
    Pictures,
    PicturesGraphics,
    PicturesPhotos,
    Software,
    SoftwareApplications,
    SoftwareGames,
}

impl NyaaCategories {
    pub fn to_category(text_category: &str) -> NyaaCategories {
        match text_category {
            "Anime - Anime Music Video" => NyaaCategories::AnimeMusicVideo,
            "Anime - English-translated" => NyaaCategories::AnimeEnglishTranslated,
            "Anime - Non-English-translated" => NyaaCategories::AnimeEnglishTranslated,
            "Anime - Raw" => NyaaCategories::AnimeRaw,
            "Audio - Lossless" => NyaaCategories::AudioLossLess,
            "Audio - Lossy" => NyaaCategories::AudioLossy,
            "Literature - English-translated" => NyaaCategories::LiteratureEnglishTranslated,
            "Literature - Non-English-translated" => NyaaCategories::LiteratureNonEnglishTranslated,
            "Literature - Raw" => NyaaCategories::LiteratureRaw,
            "Live Action - English-translated" => NyaaCategories::LiveActionEnglishTranslated,
            "Live Action - Non-English-translated" => {
                NyaaCategories::LiveActionNonEnglishTranslated
            }
            "Live Action - Idol/Promotional Video" => {
                NyaaCategories::LiveActionIdolPromotionalVideo
            }
            "Live Action - Raw" => NyaaCategories::LiveActionRaw,
            "Pictures - Graphics" => NyaaCategories::PicturesGraphics,
            "Pictures - Photos" => NyaaCategories::PicturesPhotos,
            "Software - Applications" => NyaaCategories::SoftwareApplications,
            "Software - Games" => NyaaCategories::SoftwareGames,
            &_ => NyaaCategories::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            NyaaCategories::AllCategories => "0_0".to_string(),
            NyaaCategories::Anime => "1_0".to_string(),
            NyaaCategories::AnimeMusicVideo => "1_1".to_string(),
            NyaaCategories::AnimeEnglishTranslated => "1_2".to_string(),
            NyaaCategories::AnimeNonEnglishTranslated => "1_3".to_string(),
            NyaaCategories::AnimeRaw => "1_4".to_string(),
            NyaaCategories::Audio => "2_0".to_string(),
            NyaaCategories::AudioLossLess => "2_1".to_string(),
            NyaaCategories::AudioLossy => "2_1".to_string(),
            NyaaCategories::Literature => "3_0".to_string(),
            NyaaCategories::LiteratureEnglishTranslated => "3_1".to_string(),
            NyaaCategories::LiteratureNonEnglishTranslated => "3_2".to_string(),
            NyaaCategories::LiteratureRaw => "3_3".to_string(),
            NyaaCategories::LiveAction => "4_0".to_string(),
            NyaaCategories::LiveActionEnglishTranslated => "4_1".to_string(),
            NyaaCategories::LiveActionIdolPromotionalVideo => "4_2".to_string(),
            NyaaCategories::LiveActionNonEnglishTranslated => "4_3".to_string(),
            NyaaCategories::LiveActionRaw => "4_4".to_string(),
            NyaaCategories::Pictures => "5_0".to_string(),
            NyaaCategories::PicturesGraphics => "5_1".to_string(),
            NyaaCategories::PicturesPhotos => "5_2".to_string(),
            NyaaCategories::Software => "6_0".to_string(),
            NyaaCategories::SoftwareApplications => "6_1".to_string(),
            NyaaCategories::SoftwareGames => "6_2".to_string(),
        }
    }

    pub fn all_nyaa_categories() -> Vec<Self> {
        vec![
            Self::AllCategories,
            Self::Anime,
            Self::AnimeMusicVideo,
            Self::AnimeEnglishTranslated,
            Self::AnimeNonEnglishTranslated,
            Self::AnimeRaw,
            Self::Audio,
            Self::AudioLossLess,
            Self::AudioLossy,
            Self::Literature,
            Self::LiteratureEnglishTranslated,
            Self::LiteratureNonEnglishTranslated,
            Self::LiteratureRaw,
            Self::LiveAction,
            Self::LiveActionEnglishTranslated,
            Self::LiveActionIdolPromotionalVideo,
            Self::LiveActionNonEnglishTranslated,
            Self::LiveActionRaw,
            Self::Pictures,
            Self::PicturesGraphics,
            Self::PicturesPhotos,
            Self::Software,
            Self::SoftwareApplications,
            Self::SoftwareGames,
        ]
    }
}

impl fmt::Display for NyaaCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NyaaCategories::AllCategories => write!(f, "All Categories"),
            NyaaCategories::Anime => write!(f, "Anime"),
            NyaaCategories::AnimeMusicVideo => write!(f, "Anime Music Video"),
            NyaaCategories::AnimeEnglishTranslated => write!(f, "Anime English Translated"),
            NyaaCategories::AnimeNonEnglishTranslated => write!(f, "Anime Non English Translated"),
            NyaaCategories::AnimeRaw => write!(f, "Anime Raw"),
            NyaaCategories::Audio => write!(f, "Audio"),
            NyaaCategories::AudioLossLess => write!(f, "Audio Lossless"),
            NyaaCategories::AudioLossy => write!(f, "Audio Lossy"),
            NyaaCategories::Literature => write!(f, "Literature"),
            NyaaCategories::LiteratureEnglishTranslated => {
                write!(f, "Literature English Translated")
            }
            NyaaCategories::LiteratureNonEnglishTranslated => {
                write!(f, "Literature Non English Translated")
            }
            NyaaCategories::LiteratureRaw => write!(f, "Literature Raw"),
            NyaaCategories::LiveAction => write!(f, "Live Action"),
            NyaaCategories::LiveActionEnglishTranslated => {
                write!(f, "Live Action English Translated")
            }
            NyaaCategories::LiveActionIdolPromotionalVideo => {
                write!(f, "Live Action Idol Promotional Video")
            }
            NyaaCategories::LiveActionNonEnglishTranslated => {
                write!(f, "Live Action Non English Translated")
            }
            NyaaCategories::LiveActionRaw => write!(f, "Live Action Raw"),
            NyaaCategories::Pictures => write!(f, "Pictures"),
            NyaaCategories::PicturesGraphics => write!(f, "Pictures Graphics"),
            NyaaCategories::PicturesPhotos => write!(f, "Pictures Photos"),
            NyaaCategories::Software => write!(f, "Software"),
            NyaaCategories::SoftwareApplications => write!(f, "Software Applications"),
            NyaaCategories::SoftwareGames => write!(f, "Software Games"),
        }
    }
}

pub enum NyaaFilter {
    NoFilter,
    NoRemakes,
    TrustedOnly,
}

impl NyaaFilter {
    pub fn filter_to_value(&self) -> i32 {
        match *self {
            NyaaFilter::NoFilter => 0,
            NyaaFilter::TrustedOnly => 1,
            NyaaFilter::NoRemakes => 2,
        }
    }

    pub fn to_filter(filter_str: &str) -> Self {
        match filter_str {
            "NoFilter" => NyaaFilter::NoFilter,
            "TrustedOnly" => NyaaFilter::TrustedOnly,
            "NoRemakes" => NyaaFilter::NoRemakes,
            _ => NyaaFilter::NoFilter,
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

// Scraping
pub fn scrape_and_parse(response: Response) -> Result<Vec<Torrent>, Box<dyn Error>> {
    // Scraping
    let html_response = response.text()?;
    let document = Html::parse_document(&html_response);

    // selectors
    let div_selector = Selector::parse(r#"div[class="table-responsive"]"#).unwrap();
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
        let nyaa_id: i64 = a_name[0]
            .value()
            .attr("href")
            .unwrap()
            .chars()
            .filter(|c| c.is_digit(10))
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
            .unwrap()
            .to_string();

        let torrent_file = torrent_data[0].attr("href").unwrap().to_string();
        let magnet_link = torrent_data[1].attr("href").unwrap().to_string();
        let size = table_data_vec[3].inner_html().to_string();
        let date = table_data_vec[4].inner_html().to_string();
        let seeders = table_data_vec[5].inner_html().parse::<i64>()?;
        let leechers = table_data_vec[6].inner_html().parse::<i64>()?;
        let total_downloads = table_data_vec[7].inner_html().parse::<i64>()?;

        let torrent = Torrent {
            nyaa_id,
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
