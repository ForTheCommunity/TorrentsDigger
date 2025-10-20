// https://solidtorrents.to/search?q=fate&sortBy=seeders&page=1&category=1
// https://torrentz2.nz/

use core::fmt;
use std::error::Error;

use scraper::{Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet, sources::QueryOptions, torrent::Torrent, static_includes::get_trackers,
};

#[derive(Debug)]
pub enum SolidTorrentsCategories {
    AllCategories,
    // Othee Categories
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
            sortings: true,
            filters: false,
            pagination: true,
        }
    }

    pub fn to_category(text_category: &str) -> Self {
        match text_category {
            "All Categories" => Self::AllCategories,
            "Other" => Self::Other,
            "Audio" => Self::Audio,
            "Video" => Self::Video,
            "Image" => Self::Image,
            "Document" => Self::Document,
            "Program" => Self::Program,
            "Android" => Self::Android,
            "Disk Image" => Self::DiskImage,
            "Source Code" => Self::SourceCode,
            "Database" => Self::Database,
            "Archive" => Self::Archive,
            "Movies" => Self::Movies,
            "Movies Dub Dual Audio" => Self::MoviesDubDualAudio,
            "Tv" => Self::Tv,
            "Anime" => Self::Anime,
            "Anime Dub Dual Audio" => Self::AnimeDubDualAudio,
            "Anime Subbed" => Self::AnimeSubbed,
            "Anime Raw" => Self::AnimeRaw,
            "Softwares" => Self::Softwares,
            "Softwares Windows" => Self::SoftwaresWindows,
            "Softwares Mac" => Self::SoftwaresMac,
            "Softwares Android" => Self::SoftwaresAndroid,
            "Games" => Self::Games,
            "Games Pc" => Self::GamesPc,
            "Games Mac" => Self::GamesMac,
            "Games Linux" => Self::GamesLinux,
            "Games Android" => Self::GamesAndroid,
            "Music" => Self::Music,
            "Music Mp3" => Self::MusicMp3,
            "Music Lossless" => Self::MusicLossless,
            "Music Album" => Self::MusicAlbum,
            "Music Video" => Self::MusicVideo,
            "AudioBook" => Self::AudioBook,
            "Ebook Course" => Self::EbookCourse,
            "XXX" => Self::XXX,
            &_ => Self::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            Self::AllCategories => "".to_string(),
            Self::Other => "1".to_string(),
            Self::Audio => "1-1".to_string(),
            Self::Video => "1-2".to_string(),
            Self::Image => "1-3".to_string(),
            Self::Document => "1-4".to_string(),
            Self::Program => "1-5".to_string(),
            Self::Android => "1-6".to_string(),
            Self::DiskImage => "1-7".to_string(),
            Self::SourceCode => "1-8".to_string(),
            Self::Database => "1-9".to_string(),
            Self::Archive => "1-11".to_string(),
            Self::Movies => "2".to_string(),
            Self::MoviesDubDualAudio => "2-1".to_string(),
            Self::Tv => "3".to_string(),
            Self::Anime => "4".to_string(),
            Self::AnimeDubDualAudio => "4-1".to_string(),
            Self::AnimeSubbed => "4-2".to_string(),
            Self::AnimeRaw => "4-3".to_string(),
            Self::Softwares => "5".to_string(),
            Self::SoftwaresWindows => "5-1".to_string(),
            Self::SoftwaresMac => "5-2".to_string(),
            Self::SoftwaresAndroid => "5-3".to_string(),
            Self::Games => "6".to_string(),
            Self::GamesPc => "6-1".to_string(),
            Self::GamesMac => "6-2".to_string(),
            Self::GamesLinux => "6-3".to_string(),
            Self::GamesAndroid => "6-4".to_string(),
            Self::Music => "7".to_string(),
            Self::MusicMp3 => "7-1".to_string(),
            Self::MusicLossless => "7-2".to_string(),
            Self::MusicAlbum => "7-3".to_string(),
            Self::MusicVideo => "7-4".to_string(),
            Self::AudioBook => "8".to_string(),
            Self::EbookCourse => "9".to_string(),
            Self::XXX => "10".to_string(),
        }
    }

    pub fn all_categories() -> Vec<String> {
        [
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
        ]
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
    pub fn scrape_and_parse(
        mut response: Response<Body>,
    ) -> Result<(Vec<Torrent>, Option<i64>), Box<dyn Error>> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // selectors

        // Master Selector for a single torrent entry
        let torrent_item_container_selector =
            Selector::parse("div.space-y-4 > div.bg-white.rounded-lg")?;
        let torrent_name_selector = Selector::parse("h3.line-clamp-2 a")?;
        // let category_selector = Selector::parse(
        //     ".flex-wrap.items-center.gap-4.text-sm.text-gray-600 > span:nth-child(1) > span",
        // )?;
        let size_selector = Selector::parse(
            ".flex-wrap.items-center.gap-4.text-sm.text-gray-600 > span:nth-child(2) > span",
        )?;
        let date_selector = Selector::parse(
            ".flex-wrap.items-center.gap-4.text-sm.text-gray-600 > span:nth-child(3) > span",
        )?;
        let seeders_selector = Selector::parse(".text-green-600 .font-medium")?;
        let leechers_selector = Selector::parse(".text-red-600 .font-medium")?;
        let downloads_selector = Selector::parse(".text-blue-600 .font-medium")?;
        // let active_page_selector = Selector::parse("span.bg-primary.text-white")?;
        // let next_button_selector = Selector::parse("nav.flex a")?;

        // let active_page_selector = Selector::parse("span.bg-primary.text-white")?;
        // Target all links within the <nav>
        let next_button_selector = Selector::parse("nav.flex a")?;

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

            let magnet_selector = Selector::parse("a[href^='magnet:?xt=urn:btih:']")?;

            let mut magnet = item_element
                .select(&magnet_selector)
                .next()
                .and_then(|a| a.attr("href"))
                .map_or("N/A".to_string(), |s| {
                    // The scraped magnet link already contains the trackers and other details
                    s.to_string().replace("&amp;", "&")
                });

            // extracting info hash from magnet
            let info_hash = extract_info_hash_from_magnet(&magnet).to_lowercase();
            // adding trackers
            magnet.push_str(get_trackers()?.as_str());

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
    pub fn to_sorting(sorting_str: &str) -> Self {
        match sorting_str {
            "By Relevance" => Self::ByRelevance,
            "By Seeders" => Self::BySeeders,
            "By Date" => Self::ByDate,
            "By Size" => Self::ByFileSize,
            "By Leechers" => Self::ByLeechers,
            _ => Self::ByRelevance,
        }
    }

    pub fn sorting_to_value(&self) -> String {
        match *self {
            Self::ByRelevance => "relevance".to_string(),
            Self::BySeeders => "seeders".to_string(),
            Self::ByDate => "created".to_string(),
            Self::ByFileSize => "size".to_string(),
            Self::ByLeechers => "leechers".to_string(),
        }
    }

    pub fn all_solid_torrents_sortings() -> Vec<String> {
        [
            Self::ByRelevance,
            Self::BySeeders,
            Self::ByDate,
            Self::ByFileSize,
            Self::ByLeechers,
        ]
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
