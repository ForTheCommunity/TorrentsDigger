use core::fmt;
use std::fmt::format;

use anyhow::{Ok, Result, anyhow};
use scraper::Html;
use ureq::{Body, http::Response};

use crate::{sources::QueryOptions, torrent::Torrent};

#[derive(Debug)]
pub enum PirateBayCategories {
    // All Categories
    AllCategories,
    // Audio Categories
    Audio,
    Music,
    AudioBooks,
    SoundClips,
    Flac,
    OtherAudios,
    // Video Categories
    Video,
    Movies,
    MoviesDVDR,
    MusicVideos,
    MovieClips,
    TVShows,
    HandheldVideos,
    HDMovies,
    HDTVShows,
    _3D,
    CAMTS,
    UHD4KMovies,
    UHD4KTVShows,
    OtherVideos,
    // Application Categories
    Applications,
    Windows,
    Mac,
    UNIX,
    HandheldApplications,
    IOS,
    Android,
    OtherOS,
    // Games Categories
    Games,
    PCGames,
    MacGames,
    PSxGames,
    XBOX360,
    Wii,
    HandheldGames,
    IOSGames,
    AndroidGames,
    OtherGames,
    // Porn Categories
    Porn,
    PornMovies,
    PornMoviesDVDR,
    PornPictures,
    PornGames,
    PornHDMovies,
    PornMovieClips,
    PornUHD4KMovies,
    OtherPorns,
    // Other Categories
    Other,
    EBooks,
    Comics,
    Pictures,
    Covers,
    Physibles,
    OtherOthers,
}

impl PirateBayCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: false,
            sortings: false,
            sorting_orders: false,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [PirateBayCategories] = &[
        Self::AllCategories,
        Self::Audio,
        Self::Music,
        Self::AudioBooks,
        Self::SoundClips,
        Self::Flac,
        Self::OtherAudios,
        Self::Video,
        Self::Movies,
        Self::MoviesDVDR,
        Self::MusicVideos,
        Self::MovieClips,
        Self::TVShows,
        Self::HandheldVideos,
        Self::HDMovies,
        Self::HDTVShows,
        Self::_3D,
        Self::CAMTS,
        Self::UHD4KMovies,
        Self::UHD4KTVShows,
        Self::OtherVideos,
        Self::Applications,
        Self::Windows,
        Self::Mac,
        Self::UNIX,
        Self::HandheldApplications,
        Self::IOS,
        Self::Android,
        Self::OtherOS,
        Self::Games,
        Self::PCGames,
        Self::MacGames,
        Self::PSxGames,
        Self::XBOX360,
        Self::Wii,
        Self::HandheldGames,
        Self::IOSGames,
        Self::AndroidGames,
        Self::OtherGames,
        Self::Porn,
        Self::PornMovies,
        Self::PornMoviesDVDR,
        Self::PornPictures,
        Self::PornGames,
        Self::PornHDMovies,
        Self::PornMovieClips,
        Self::PornUHD4KMovies,
        Self::OtherPorns,
        Self::Other,
        Self::EBooks,
        Self::Comics,
        Self::Pictures,
        Self::Covers,
        Self::Physibles,
        Self::OtherOthers,
    ];

    pub fn from_index(index: usize) -> Option<&'static PirateBayCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "0",
            Self::Audio => "100",
            Self::Music => "101",
            Self::AudioBooks => "102",
            Self::SoundClips => "103",
            Self::Flac => "104",
            Self::OtherAudios => "199",
            Self::Video => "200",
            Self::Movies => "201",
            Self::MoviesDVDR => "202",
            Self::MusicVideos => "203",
            Self::MovieClips => "204",
            Self::TVShows => "205",
            Self::HandheldVideos => "206",
            Self::HDMovies => "207",
            Self::HDTVShows => "208",
            Self::_3D => "209",
            Self::CAMTS => "210",
            Self::UHD4KMovies => "211",
            Self::UHD4KTVShows => "212",
            Self::OtherVideos => "299",
            Self::Applications => "300",
            Self::Windows => "301",
            Self::Mac => "302",
            Self::UNIX => "303",
            Self::HandheldApplications => "304",
            Self::IOS => "305",
            Self::Android => "306",
            Self::OtherOS => "399",
            Self::Games => "400",
            Self::PCGames => "401",
            Self::MacGames => "402",
            Self::PSxGames => "403",
            Self::XBOX360 => "404",
            Self::Wii => "405",
            Self::HandheldGames => "406",
            Self::IOSGames => "407",
            Self::AndroidGames => "408",
            Self::OtherGames => "499",
            Self::Porn => "500",
            Self::PornMovies => "501",
            Self::PornMoviesDVDR => "502",
            Self::PornPictures => "503",
            Self::PornGames => "504",
            Self::PornHDMovies => "505",
            Self::PornMovieClips => "506",
            Self::PornUHD4KMovies => "507",
            Self::OtherPorns => "599",
            Self::Other => "600",
            Self::EBooks => "601",
            Self::Comics => "602",
            Self::Pictures => "603",
            Self::Covers => "604",
            Self::Physibles => "605",
            Self::OtherOthers => "699",
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
        category: &PirateBayCategories,
        page_number: &i64,
    ) -> String {
        // https://thepiratebay.party/search/boruto/1/99/0

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://thepiratebay.party";
        let path = "search";

        let category = format!("{}", category.category_to_value());

        format!(
            "{}/{}/{}/{}/99/{}",
            root_url, path, torrent_name, page_number, category
        )
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
        // Scraping
        let html_response = response
            .body_mut()
            .read_to_string()
            .map_err(|e| anyhow!(format!("Error reading response body: {}", e)))?;
        let document = Html::parse_document(&html_response);

        // TODO

        let mock_torrent_1: Torrent = Torrent {
            info_hash: "mock_ih_1".to_string(),
            name: "Debian 12 ISO".to_string(),
            magnet: "magnet:?xt=urn:btih:EE34425D58C94DAme".to_string(),
            size: "2 GB".to_string(),
            date: "Today".to_string(),
            seeders: "100".to_string(),
            leechers: "2".to_string(),
            total_downloads: "8346".to_string(),
        };

        let mock_torrent_2: Torrent = Torrent {
            info_hash: "mock_ih_2".to_string(),
            name: "Debian 11 ISO".to_string(),
            magnet: "magnet:?xt=urn:btih:EE34425D58C94DAme".to_string(),
            size: "1.7 GB".to_string(),
            date: "Yesterday".to_string(),
            seeders: "158".to_string(),
            leechers: "513".to_string(),
            total_downloads: "8346".to_string(),
        };

        let vec_torr: Vec<Torrent> = vec![mock_torrent_1, mock_torrent_2];
        Ok((vec_torr, None))
        //         todo!()
    }
}

impl fmt::Display for PirateBayCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Audio => write!(f, "Audio"),
            Self::Music => write!(f, "Music"),
            Self::AudioBooks => write!(f, "AudioBooks"),
            Self::SoundClips => write!(f, "Sound Clips"),
            Self::Flac => write!(f, "FLAC"),
            Self::OtherAudios => write!(f, "Other Audios"),
            Self::Video => write!(f, "Video"),
            Self::Movies => write!(f, "Movies"),
            Self::MoviesDVDR => write!(f, "Movies DVDR"),
            Self::MusicVideos => write!(f, "Music Videos"),
            Self::MovieClips => write!(f, "Movie Clips"),
            Self::TVShows => write!(f, "Tv Shows"),
            Self::HandheldVideos => write!(f, "Handheld"),
            Self::HDMovies => write!(f, "HD Movies"),
            Self::HDTVShows => write!(f, "HD Tv Shows"),
            Self::_3D => write!(f, "3D"),
            Self::CAMTS => write!(f, "CAM / TS"),
            Self::UHD4KMovies => write!(f, "UHD / 4K Movies"),
            Self::UHD4KTVShows => write!(f, "UHD / 4K TV Shows"),
            Self::OtherVideos => write!(f, "Other Videos"),
            Self::Applications => write!(f, "Applications"),
            Self::Windows => write!(f, "Windows"),
            Self::Mac => write!(f, "Mac"),
            Self::UNIX => write!(f, "UNIX"),
            Self::HandheldApplications => write!(f, "Handheld Applications"),
            Self::IOS => write!(f, "IOS"),
            Self::Android => write!(f, "Android"),
            Self::OtherOS => write!(f, "Other OS"),
            Self::Games => write!(f, "Games"),
            Self::PCGames => write!(f, "PC Games"),
            Self::MacGames => write!(f, "Mac Games"),
            Self::PSxGames => write!(f, "PSx Games"),
            Self::XBOX360 => write!(f, "XBOX 360"),
            Self::Wii => write!(f, "Wii"),
            Self::HandheldGames => write!(f, "Handheld Games"),
            Self::IOSGames => write!(f, "IOS Games"),
            Self::AndroidGames => write!(f, "Android Games"),
            Self::OtherGames => write!(f, "Other Games"),
            Self::Porn => write!(f, "Porn"),
            Self::PornMovies => write!(f, "Porn Movies"),
            Self::PornMoviesDVDR => write!(f, "Porn DVDR Movies"),
            Self::PornPictures => write!(f, "Porn Pictures"),
            Self::PornGames => write!(f, "Porn Games"),
            Self::PornHDMovies => write!(f, "Porn HD Movies"),
            Self::PornMovieClips => write!(f, "Porn Movie Clips"),
            Self::PornUHD4KMovies => write!(f, "Porn UHD 4K Movies"),
            Self::OtherPorns => write!(f, "Other Porns"),
            Self::Other => write!(f, "Other"),
            Self::EBooks => write!(f, "E-Books"),
            Self::Comics => write!(f, "Comics"),
            Self::Pictures => write!(f, "Pictures"),
            Self::Covers => write!(f, "Covers"),
            Self::Physibles => write!(f, "Physibles"),
            Self::OtherOthers => write!(f, "Other Others"),
        }
    }
}
