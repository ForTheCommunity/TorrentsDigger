use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{self, ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{extract_info_hash_from_magnet, sources::QueryOptions, torrent::Torrent};

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
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [NyaaCategories] = &[
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
    ];

    pub fn from_index(index: usize) -> Option<&'static NyaaCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "0_0",
            Self::Anime => "1_0",
            Self::AnimeMusicVideo => "1_1",
            Self::AnimeEnglishTranslated => "1_2",
            Self::AnimeNonEnglishTranslated => "1_3",
            Self::AnimeRaw => "1_4",
            Self::Audio => "2_0",
            Self::AudioLossLess => "2_1",
            Self::AudioLossy => "2_1",
            Self::Literature => "3_0",
            Self::LiteratureEnglishTranslated => "3_1",
            Self::LiteratureNonEnglishTranslated => "3_2",
            Self::LiteratureRaw => "3_3",
            Self::LiveAction => "4_0",
            Self::LiveActionEnglishTranslated => "4_1",
            Self::LiveActionIdolPromotionalVideo => "4_2",
            Self::LiveActionNonEnglishTranslated => "4_3",
            Self::LiveActionRaw => "4_4",
            Self::Pictures => "5_0",
            Self::PicturesGraphics => "5_1",
            Self::PicturesPhotos => "5_2",
            Self::Software => "6_0",
            Self::SoftwareApplications => "6_1",
            Self::SoftwareGames => "6_2",
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
        category: &NyaaCategories,
        sorting: &NyaaSortings,
        page_number: &i64,
    ) -> String {
        //https://nyaa.si/?f=0&c=1_0&q=naruto&s=seeders&o=desc&p=2

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

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
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
        // Scraping
        let html_response = response
            .body_mut()
            .read_to_string()
            .map_err(|e| anyhow!(format!("Error reading response body: {}", e)))?;
        let document = Html::parse_document(&html_response);

        // selectors
        let div_selector = Selector::parse(r#"div[class="table-responsive"]"#)
            .map_err(|e| anyhow!(format!("Error parsing div selector: {}", e)))?;

        let table_selector = Selector::parse("table")
            .map_err(|e| anyhow!(format!("Error parsing table selector: {}", e)))?;

        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!(format!("Error parsing tbody selector: {}", e)))?;

        let table_row_selector = Selector::parse("tr")
            .map_err(|e| anyhow!(format!("Error parsing tr selector: {}", e)))?;

        let table_data_selector = Selector::parse("td")
            .map_err(|e| anyhow!(format!("Error parsing td selector: {}", e)))?;

        let anchor_tag_selector = Selector::parse("a")
            .map_err(|e| anyhow!(format!("Error parsing a selector: {}", e)))?;

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
            .ok_or_else(|| anyhow!("No Table Found....."))?;
        let table_body = table
            .select(&table_body_selector)
            .next()
            .ok_or_else(|| anyhow!("Didn't found Table Body."))?;

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

    const ALL_VARIANTS: &'static [NyaaFilter] =
        &[Self::NoFilter, Self::TrustedOnly, Self::NoRemakes];

    pub fn from_index(index: usize) -> Option<&'static NyaaFilter> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_nyaa_filters() -> Vec<String> {
        Self::ALL_VARIANTS
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

    pub fn sorting_to_value(&self) -> &str {
        match *self {
            Self::ByComments => "comments",
            Self::BySize => "size",
            Self::ByDate => "id",
            Self::BySeeders => "seeders",
            Self::ByLeechers => "leechers",
            Self::ByTotalDownloads => "downloads",
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
