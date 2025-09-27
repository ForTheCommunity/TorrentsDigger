use core::fmt;
use std::error::Error;

use anyhow::Result;
use scraper::{self, ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{sources::QueryOptions, torrent::Torrent, trackers::get_trackers};

// https://nyaa.si

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
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            sortings: true,
            filters: true,
        }
    }
    pub fn to_category(text_category: &str) -> Self {
        match text_category {
            "All Categories" => Self::AllCategories,
            "Anime" => Self::Anime,
            "Anime Music Video" => Self::AnimeMusicVideo,
            "Anime English Translated" => Self::AnimeEnglishTranslated,
            "Anime Non English Translated" => Self::AnimeNonEnglishTranslated,
            "Anime Raw" => Self::AnimeRaw,
            "Audio" => Self::Audio,
            "Audio Lossless" => Self::AudioLossLess,
            "Audio Lossy" => Self::AudioLossy,
            "Literature" => Self::Literature,
            "Literature English Translated" => Self::LiteratureEnglishTranslated,
            "Literature Non English Translated" => Self::LiteratureNonEnglishTranslated,
            "Literature Raw" => Self::LiteratureRaw,
            "Live Action" => Self::LiveAction,
            "Live Action English Translated" => Self::LiveActionEnglishTranslated,
            "Live Action Non English Translated" => Self::LiveActionNonEnglishTranslated,
            "Live Action Idol Promotional Video" => Self::LiveActionIdolPromotionalVideo,
            "Live Action Raw" => Self::LiveActionRaw,
            "Pictures" => Self::Pictures,
            "Pictures Graphics" => Self::PicturesGraphics,
            "Pictures Photos" => Self::PicturesPhotos,
            "Software" => Self::Software,
            "Software Applications" => Self::SoftwareApplications,
            "Software Games" => Self::SoftwareGames,
            &_ => Self::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            Self::AllCategories => "0_0".to_string(),
            Self::Anime => "1_0".to_string(),
            Self::AnimeMusicVideo => "1_1".to_string(),
            Self::AnimeEnglishTranslated => "1_2".to_string(),
            Self::AnimeNonEnglishTranslated => "1_3".to_string(),
            Self::AnimeRaw => "1_4".to_string(),
            Self::Audio => "2_0".to_string(),
            Self::AudioLossLess => "2_1".to_string(),
            Self::AudioLossy => "2_1".to_string(),
            Self::Literature => "3_0".to_string(),
            Self::LiteratureEnglishTranslated => "3_1".to_string(),
            Self::LiteratureNonEnglishTranslated => "3_2".to_string(),
            Self::LiteratureRaw => "3_3".to_string(),
            Self::LiveAction => "4_0".to_string(),
            Self::LiveActionEnglishTranslated => "4_1".to_string(),
            Self::LiveActionIdolPromotionalVideo => "4_2".to_string(),
            Self::LiveActionNonEnglishTranslated => "4_3".to_string(),
            Self::LiveActionRaw => "4_4".to_string(),
            Self::Pictures => "5_0".to_string(),
            Self::PicturesGraphics => "5_1".to_string(),
            Self::PicturesPhotos => "5_2".to_string(),
            Self::Software => "6_0".to_string(),
            Self::SoftwareApplications => "6_1".to_string(),
            Self::SoftwareGames => "6_2".to_string(),
        }
    }

    pub fn all_categories() -> Vec<String> {
        [
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
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        filter: &NyaaFilter,
        category: &NyaaCategories,
        sorting: &NyaaSortings,
        page_number: &i64,
    ) -> String {
        //https://nyaa.si/?f=0&c=1_0&q=naruto&s=seeders&o=desc&p=2

        let torrent_name = torrent_name
            .split_whitespace()
            .collect::<Vec<&str>>()
            .join("+");

        let root_url = "https://nyaa.si";
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

            let mut magnet_link = if torrent_data.len() > 1 {
                torrent_data[1].attr("href").unwrap_or_default().to_string()
            } else {
                String::from("Magnet link not available")
            };

            // adding extra trackers
            magnet_link.push_str(get_trackers()?.as_str());

            let size = table_data_vec[3].inner_html().to_string();
            let date = table_data_vec[4].inner_html().to_string();
            let seeders = table_data_vec[5].inner_html().parse::<i64>()?;
            let leechers = table_data_vec[6].inner_html().parse::<i64>()?;
            let total_downloads = table_data_vec[7].inner_html().parse::<i64>()?;

            let torrent = Torrent {
                id,
                name,
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

impl fmt::Display for NyaaCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Anime => write!(f, "Anime"),
            Self::AnimeMusicVideo => write!(f, "Anime Music Video"),
            Self::AnimeEnglishTranslated => write!(f, "Anime English Translated"),
            Self::AnimeNonEnglishTranslated => write!(f, "Anime Non English Translated"),
            Self::AnimeRaw => write!(f, "Anime Raw"),
            Self::Audio => write!(f, "Audio"),
            Self::AudioLossLess => write!(f, "Audio Lossless"),
            Self::AudioLossy => write!(f, "Audio Lossy"),
            Self::Literature => write!(f, "Literature"),
            Self::LiteratureEnglishTranslated => {
                write!(f, "Literature English Translated")
            }
            Self::LiteratureNonEnglishTranslated => {
                write!(f, "Literature Non English Translated")
            }
            Self::LiteratureRaw => write!(f, "Literature Raw"),
            Self::LiveAction => write!(f, "Live Action"),
            Self::LiveActionEnglishTranslated => {
                write!(f, "Live Action English Translated")
            }
            Self::LiveActionNonEnglishTranslated => {
                write!(f, "Live Action Non English Translated")
            }
            Self::LiveActionIdolPromotionalVideo => {
                write!(f, "Live Action Idol Promotional Video")
            }
            Self::LiveActionRaw => write!(f, "Live Action Raw"),
            Self::Pictures => write!(f, "Pictures"),
            Self::PicturesGraphics => write!(f, "Pictures Graphics"),
            Self::PicturesPhotos => write!(f, "Pictures Photos"),
            Self::Software => write!(f, "Software"),
            Self::SoftwareApplications => write!(f, "Software Applications"),
            Self::SoftwareGames => write!(f, "Software Games"),
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
    pub fn all_nyaa_filters() -> Vec<String> {
        [Self::NoFilter, Self::TrustedOnly, Self::NoRemakes]
            .iter()
            .map(|filter| filter.to_string())
            .collect()
    }
}

impl fmt::Display for NyaaFilter {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NoFilter => write!(f, "No Filter"),
            Self::TrustedOnly => write!(f, "Trusted Only"),
            Self::NoRemakes => write!(f, "No Remakes"),
        }
    }
}

pub enum NyaaSortings {
    ByComments,
    BySize,
    ByDate,
    BySeeders,
    ByLeechers,
    ByTotalDownloads,
}

impl NyaaSortings {
    pub fn to_sorting(sorting_str: &str) -> Self {
        match sorting_str {
            "By Comments" => Self::ByComments,
            "By Size" => Self::BySize,
            "By Date" => Self::ByDate,
            "By Seeders" => Self::BySeeders,
            "By Leechers" => Self::ByLeechers,
            "By Total Downloads" => Self::ByTotalDownloads,
            _ => Self::BySeeders,
        }
    }

    pub fn sorting_to_value(&self) -> String {
        match *self {
            Self::ByComments => "comments".to_string(),
            Self::BySize => "size".to_string(),
            Self::ByDate => "id".to_string(),
            Self::BySeeders => "seeders".to_string(),
            Self::ByLeechers => "leechers".to_string(),
            Self::ByTotalDownloads => "downloads".to_string(),
        }
    }

    pub fn all_nyaa_sortings() -> Vec<String> {
        [
            Self::ByComments,
            Self::BySize,
            Self::ByDate,
            Self::BySeeders,
            Self::ByLeechers,
            Self::ByTotalDownloads,
        ]
        .iter()
        .map(|sorting| sorting.to_string())
        .collect()
    }
}

impl fmt::Display for NyaaSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ByComments => write!(f, "By Comments"),
            Self::BySize => write!(f, "By Size"),
            Self::ByDate => write!(f, "By Date"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
            Self::ByTotalDownloads => write!(f, "By Total Downloads"),
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
        let torrent_query_name = "naruto";
        let filter = NyaaFilter::TrustedOnly;
        let category = NyaaCategories::Anime;
        let sorting = NyaaSortings::BySeeders;
        let page_number = 1;

        assert_eq!(
            "https://nyaa.si/?f=0&c=1_0&q=naruto&s=seeders&o=desc&p=1".to_string(),
            NyaaCategories::request_url_builder(
                torrent_query_name,
                &filter,
                &category,
                &sorting,
                &page_number
            )
        );
    }
}
