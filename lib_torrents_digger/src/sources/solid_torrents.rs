// https://solidtorrents.to/search?q=fate&sortBy=seeders&page=1&category=1
// https://torrentz2.nz/

use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{Html, Selector};
use ureq::{Body, http::Response};

use crate::{extract_info_hash_from_magnet, sources::QueryOptions, torrent::Torrent};

#[derive(Debug)]
pub enum SolidTorrentsCategories {
    AllCategories,
    // Others Categories
    Other,
    Audio,
    Video,
    Image,
    Document,
    Program,
    Android,
    DiskImage,
    SourceCode,
    Database,
    Archive,
    // Movies Categories
    Movies,
    MoviesDubDualAudio,
    // Tv Category
    Tv,
    // Anime Categories
    Anime,
    AnimeDubDualAudio,
    AnimeSubbed,
    AnimeRaw,
    // Software Categories
    Softwares,
    SoftwaresWindows,
    SoftwaresMac,
    SoftwaresAndroid,
    // Games Categories
    Games,
    GamesPc,
    GamesMac,
    GamesLinux,
    GamesAndroid,
    // Music Categories
    Music,
    MusicMp3,
    MusicLossless,
    MusicAlbum,
    MusicVideo,
    // Audiobook Category
    AudioBook,
    // Ebook Category
    EbookCourse,
    // Nsfw Category
    XXX,
}

impl SolidTorrentsCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: false,
            sortings: true,
            sorting_orders: false,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [SolidTorrentsCategories] = &[
        Self::AllCategories,
        Self::Other,
        Self::Audio,
        Self::Video,
        Self::Image,
        Self::Document,
        Self::Program,
        Self::Android,
        Self::DiskImage,
        Self::SourceCode,
        Self::Database,
        Self::Archive,
        Self::Movies,
        Self::MoviesDubDualAudio,
        Self::Tv,
        Self::Anime,
        Self::AnimeDubDualAudio,
        Self::AnimeSubbed,
        Self::AnimeRaw,
        Self::Softwares,
        Self::SoftwaresWindows,
        Self::SoftwaresMac,
        Self::SoftwaresAndroid,
        Self::Games,
        Self::GamesPc,
        Self::GamesMac,
        Self::GamesLinux,
        Self::GamesAndroid,
        Self::Music,
        Self::MusicMp3,
        Self::MusicLossless,
        Self::MusicAlbum,
        Self::MusicVideo,
        Self::AudioBook,
        Self::EbookCourse,
        Self::XXX,
    ];

    pub fn from_index(index: usize) -> Option<&'static SolidTorrentsCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "",
            Self::Other => "1",
            Self::Audio => "1-1",
            Self::Video => "1-2",
            Self::Image => "1-3",
            Self::Document => "1-4",
            Self::Program => "1-5",
            Self::Android => "1-6",
            Self::DiskImage => "1-7",
            Self::SourceCode => "1-8",
            Self::Database => "1-9",
            Self::Archive => "1-11",
            Self::Movies => "2",
            Self::MoviesDubDualAudio => "2-1",
            Self::Tv => "3",
            Self::Anime => "4",
            Self::AnimeDubDualAudio => "4-1",
            Self::AnimeSubbed => "4-2",
            Self::AnimeRaw => "4-3",
            Self::Softwares => "5",
            Self::SoftwaresWindows => "5-1",
            Self::SoftwaresMac => "5-2",
            Self::SoftwaresAndroid => "5-3",
            Self::Games => "6",
            Self::GamesPc => "6-1",
            Self::GamesMac => "6-2",
            Self::GamesLinux => "6-3",
            Self::GamesAndroid => "6-4",
            Self::Music => "7",
            Self::MusicMp3 => "7-1",
            Self::MusicLossless => "7-2",
            Self::MusicAlbum => "7-3",
            Self::MusicVideo => "7-4",
            Self::AudioBook => "8",
            Self::EbookCourse => "9",
            Self::XXX => "10",
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
        category: &SolidTorrentsCategories,
        sorting: &SolidTorrentsSortings,
        page_number: &i64,
    ) -> String {
        // https://solidtorrents.to/search?q=fate&page=1&sortBy=leechers&category=1

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://solidtorrents.to";
        let path = "search";
        let query = format!("q={}", torrent_name);
        let category = format!("category={}", category.category_to_value());
        let sorting = format!("sortBy={}", sorting.sorting_to_value());
        let page_number = format!("page={}", page_number);

        format!(
            "{}/{}?{}&{}&{}&{}",
            root_url, path, query, page_number, sorting, category
        )
    }

    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // selectors

        // Master Selector for a single torrent entry
        let torrent_item_container_selector =
            Selector::parse("div.space-y-4 > div.bg-white.rounded-lg")
                .map_err(|e| anyhow!(format!("Error parsing container selector: {}", e)))?;

        let torrent_name_selector = Selector::parse("h3.line-clamp-2 a")
            .map_err(|e| anyhow!(format!("Error parsing torrent name selector: {}", e)))?;

        let size_selector = Selector::parse(
            ".flex-wrap.items-center.gap-4.text-sm.text-gray-600 > span:nth-child(2) > span",
        )
        .map_err(|e| anyhow!(format!("Error parsing size selector: {}", e)))?;

        let date_selector = Selector::parse(
            ".flex-wrap.items-center.gap-4.text-sm.text-gray-600 > span:nth-child(3) > span",
        )
        .map_err(|e| anyhow!(format!("Error parsing date selector: {}", e)))?;

        let seeders_selector = Selector::parse(".text-green-600 .font-medium")
            .map_err(|e| anyhow!(format!("Error parsing seeders selector: {}", e)))?;

        let leechers_selector = Selector::parse(".text-red-600 .font-medium")
            .map_err(|e| anyhow!(format!("Error parsing leechers selector: {}", e)))?;

        let downloads_selector = Selector::parse(".text-blue-600 .font-medium")
            .map_err(|e| anyhow!(format!("Error parsing downloads selector: {}", e)))?;

        // let active_page_selector = Selector::parse("span.bg-primary.text-white")?;
        // let next_button_selector = Selector::parse("nav.flex a")?;

        // let active_page_selector = Selector::parse("span.bg-primary.text-white")?;
        // Target all links within the <nav>
        let next_button_selector = Selector::parse("nav.flex a")
            .map_err(|e| anyhow!(format!("Error parsing next button selector: {}", e)))?;

        // Vector to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let mut next_page_num: Option<i64> = None;
        // Iterate over all 'a' tags in the pagination <nav>
        for a_tag in document.select(&next_button_selector) {
            if a_tag.inner_html().contains("Next")
                && let Some(href) = a_tag.attr("href")
            {
                if let Some(query) = href.split('?').nth(1)
                    && let Some(page_param) =
                        query.split('&').find(|param| param.starts_with("page="))
                    && let Some(next_page_str) = page_param.split('=').nth(1)
                    && let Ok(num) = next_page_str.parse::<i64>()
                {
                    next_page_num = Some(num);
                }
                // Break after finding the 'Next' button
                break;
            }
        }

        // iterating over all torrents
        for item_element in document.select(&torrent_item_container_selector) {
            let anchor_tag = item_element.select(&torrent_name_selector).next();

            let name = anchor_tag.map_or("N/A".to_string(), |a| {
                a.text().collect::<String>().trim().to_string()
            });

            // size
            let size = item_element
                .select(&size_selector)
                .next()
                .map_or("N/A".to_string(), |e| {
                    e.text().collect::<String>().trim().to_string()
                });

            // Date
            let date = item_element
                .select(&date_selector)
                .next()
                .map_or("N/A".to_string(), |e| {
                    e.text().collect::<String>().trim().to_string()
                });

            let seeders = item_element
                .select(&seeders_selector)
                .next()
                .map_or("N/A".to_string(), |e| {
                    e.text().collect::<String>().trim().to_string()
                });

            let leechers = item_element
                .select(&leechers_selector)
                .next()
                .map_or("N/A".to_string(), |e| {
                    e.text().collect::<String>().trim().to_string()
                });

            let total_downloads = item_element
                .select(&downloads_selector)
                .next()
                .map_or("N/A".to_string(), |e| {
                    e.text().collect::<String>().trim().to_string()
                });

            let magnet_selector = Selector::parse("a[href^='magnet:?xt=urn:btih:']")
                .map_err(|e| anyhow!(format!("Error parsing magnet selector: {}", e)))?;

            let magnet = item_element
                .select(&magnet_selector)
                .next()
                .and_then(|a| a.attr("href"))
                .map_or("N/A".to_string(), |s| {
                    // The scraped magnet link already contains the trackers and other details
                    s.to_string().replace("&amp;", "&")
                });

            // extracting info hash from magnet
            let info_hash = extract_info_hash_from_magnet(&magnet).to_lowercase();

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

        Ok((all_torrents, next_page_num))
    }
}

impl fmt::Display for SolidTorrentsCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Other => write!(f, "Other"),
            Self::Audio => write!(f, "Audio"),
            Self::Video => write!(f, "Video"),
            Self::Image => write!(f, "Image"),
            Self::Document => write!(f, "Document"),
            Self::Program => write!(f, "Program"),
            Self::Android => write!(f, "Android"),
            Self::DiskImage => write!(f, "Disk Image"),
            Self::SourceCode => write!(f, "Source Code"),
            Self::Database => write!(f, "Database"),
            Self::Archive => write!(f, "Archive"),
            Self::Movies => write!(f, "Movies"),
            Self::MoviesDubDualAudio => write!(f, "Movies Dub Dual Audio"),
            Self::Tv => write!(f, "Tv"),
            Self::Anime => write!(f, "Anime"),
            Self::AnimeDubDualAudio => write!(f, "Anime Dub Dual Audio"),
            Self::AnimeSubbed => write!(f, "Anime Subbed"),
            Self::AnimeRaw => write!(f, "Anime Raw"),
            Self::Softwares => write!(f, "Softwares"),
            Self::SoftwaresWindows => write!(f, "Softwares Windows"),
            Self::SoftwaresMac => write!(f, "Softwares Mac"),
            Self::SoftwaresAndroid => write!(f, "Softwares Android"),
            Self::Games => write!(f, "Games"),
            Self::GamesPc => write!(f, "Games Pc"),
            Self::GamesMac => write!(f, "Games Mac"),
            Self::GamesLinux => write!(f, "Games Linux"),
            Self::GamesAndroid => write!(f, "Games Android"),
            Self::Music => write!(f, "Music"),
            Self::MusicMp3 => write!(f, "Music Mp3"),
            Self::MusicLossless => write!(f, "Music Lossless"),
            Self::MusicAlbum => write!(f, "Music Album"),
            Self::MusicVideo => write!(f, "Music Video"),
            Self::AudioBook => write!(f, "AudioBook"),
            Self::EbookCourse => write!(f, "Ebook Course"),
            Self::XXX => write!(f, "XXX"),
        }
    }
}

pub enum SolidTorrentsSortings {
    ByRelevance,
    BySeeders,
    ByDate,
    ByFileSize,
    ByLeechers,
}

impl SolidTorrentsSortings {
    const ALL_VARIANTS: &'static [SolidTorrentsSortings] = &[
        Self::ByRelevance,
        Self::BySeeders,
        Self::ByDate,
        Self::ByFileSize,
        Self::ByLeechers,
    ];

    pub fn from_index(index: usize) -> Option<&'static SolidTorrentsSortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_to_value(&self) -> &str {
        match *self {
            Self::ByRelevance => "relevance",
            Self::BySeeders => "seeders",
            Self::ByDate => "created",
            Self::ByFileSize => "size",
            Self::ByLeechers => "leechers",
        }
    }

    pub fn all_solid_torrents_sortings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for SolidTorrentsSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ByRelevance => write!(f, "By Relevance"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByDate => write!(f, "By Date"),
            Self::ByFileSize => write!(f, "By Size"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}
