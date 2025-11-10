// Knaben Database

use anyhow::{Result, anyhow};
use core::fmt;

use scraper::{ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{sources::QueryOptions, torrent::Torrent};

#[derive(Debug)]
pub enum KnabenDatabaseCategories {
    AllCategories, // 'All' category on website
    // Audio Categories
    Audio,
    AudioMp3,
    AudioLossless,
    AudioAudioBook,
    AudioVideo,
    AudioRadio,
    AudioOther,
    // TV Categories
    Tv,
    TvHD,
    TvSD,
    TvUHD,
    TvDocumentary,
    TvForeign,
    TvSport,
    TvCartoon,
    TvOther,
    // Movies Categories
    Movies,
    MoviesHD,
    MoviesSD,
    MoviesUHD,
    MoviesDVD,
    MoviesForeign,
    MoviesBollywood,
    Movies3D,
    MoviesOther,
    // PC Categories
    PC,
    PCGames,
    PCSoftware,
    PCMac,
    PCUnix,
    // NSFW Categories
    XXX,
    XXXVideo,
    XXXImageSet,
    XXXGames,
    XXXHentai,
    XXXOther,
    // Anime Categories
    Anime,
    AnimeSubbed,
    AnimeDubbed,
    AnimeDualAudio,
    AnimeRaw,
    AnimeMusicVideo,
    AnimeLiterature,
    AnimeMusic,
    AnimeNonEnglishTranslated,
    // Console Categories
    Console,
    ConsolePS4,
    ConsolePS3,
    ConsolePS2,
    ConsolePS1,
    ConsolePSVita,
    ConsolePSP,
    ConsoleXbox360,
    ConsoleXbox,
    ConsoleSwitch,
    ConsoleNDS,
    ConsoleWii,
    ConsoleWiiU,
    Console3DS,
    ConsoleGameCube,
    ConsoleOther,
    // Mobile Categories
    Mobile,
    MobileAndroid,
    MobileIOS,
    MobileOther,
    // Books Categories
    Books,
    BooksEbooks,
    BooksComics,
    BooksMagazines,
    BooksTechnical,
    BooksOther,
    // Other Categories
    Other,
    OtherMisc,
}

impl KnabenDatabaseCategories {
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
            "Audio" => Self::Audio,
            "Audio Mp3" => Self::AudioMp3,
            "Audio Lossless" => Self::AudioLossless,
            "AudioBook" => Self::AudioAudioBook,
            "Audio Video" => Self::AudioVideo,
            "Audio Radio" => Self::AudioRadio,
            "Audio Other" => Self::AudioOther,
            "Tv" => Self::Tv,
            "HD Tv" => Self::TvHD,
            "SD Tv" => Self::TvSD,
            "UHD Tv" => Self::TvUHD,
            "Tv Documentary" => Self::TvDocumentary,
            "Foreign Tv" => Self::TvForeign,
            "Sport Tv" => Self::TvSport,
            "Cartoon Tv" => Self::TvCartoon,
            "Other Tv" => Self::TvOther,
            "Movies" => Self::Movies,
            "HD Movies" => Self::MoviesHD,
            "SD Movies" => Self::MoviesSD,
            "UHD Movies" => Self::MoviesUHD,
            "DVD Movies" => Self::MoviesDVD,
            "Foreign Movies" => Self::MoviesForeign,
            "Bollywood Movies" => Self::MoviesBollywood,
            "3D Movies" => Self::Movies3D,
            "Other Movies" => Self::MoviesOther,
            "PC" => Self::PC,
            "PC Games" => Self::PCGames,
            "PC Software" => Self::PCSoftware,
            "PC Mac" => Self::PCMac,
            "PC Unix" => Self::PCUnix,
            "XXX" => Self::XXX,
            "XXX Video" => Self::XXXVideo,
            "XXX ImageSet" => Self::XXXImageSet,
            "XXX Games" => Self::XXXGames,
            "XXX Hentai" => Self::XXXHentai,
            "Other XXX" => Self::XXXOther,
            "Anime" => Self::Anime,
            "Subbed Anime" => Self::AnimeSubbed,
            "Dubbed Anime" => Self::AnimeDubbed,
            "Dual Audio Anime" => Self::AnimeDualAudio,
            "Raw Anime" => Self::AnimeRaw,
            "Anime Music Video" => Self::AnimeMusicVideo,
            "Anime Literature" => Self::AnimeLiterature,
            "Anime Music" => Self::AnimeMusic,
            "Non English Translated Anime" => Self::AnimeNonEnglishTranslated,
            "Console" => Self::Console,
            "PS4" => Self::ConsolePS4,
            "PS3" => Self::ConsolePS3,
            "PS2" => Self::ConsolePS2,
            "PS1" => Self::ConsolePS1,
            "PS Vita" => Self::ConsolePSVita,
            "PSP" => Self::ConsolePSP,
            "Xbox360" => Self::ConsoleXbox360,
            "Xbox" => Self::ConsoleXbox,
            "Switch" => Self::ConsoleSwitch,
            "Nintendo Switch" => Self::ConsoleNDS,
            "Nintendo Wii" => Self::ConsoleWii,
            "Nintendo WiiU" => Self::ConsoleWiiU,
            "Nintendo 3DS" => Self::Console3DS,
            "Nintendo GameCube" => Self::ConsoleGameCube,
            "Other Console" => Self::ConsoleOther,
            "Mobile" => Self::Mobile,
            "Android Mobile" => Self::MobileAndroid,
            "IOS Mobile" => Self::MobileIOS,
            "Other Mobile" => Self::MobileOther,
            "Books" => Self::Books,
            "Ebooks" => Self::BooksEbooks,
            "Comics" => Self::BooksComics,
            "Magazines" => Self::BooksMagazines,
            "Technical Books" => Self::BooksTechnical,
            "Other Books" => Self::BooksOther,
            "Other" => Self::Other,
            "Other Misc" => Self::OtherMisc,
            &_ => Self::AllCategories,
        }
    }

    pub fn to_value(&self) -> &str {
        match *self {
            Self::AllCategories => "000000000",
            Self::Audio => "1000000",
            Self::AudioMp3 => "1001000",
            Self::AudioLossless => "1002000",
            Self::AudioAudioBook => "1003000",
            Self::AudioVideo => "1004000",
            Self::AudioRadio => "1005000",
            Self::AudioOther => "1006000",
            Self::Tv => "2000000",
            Self::TvHD => "2001000",
            Self::TvSD => "2002000",
            Self::TvUHD => "2003000",
            Self::TvDocumentary => "2004000",
            Self::TvForeign => "2005000",
            Self::TvSport => "2006000",
            Self::TvCartoon => "2007000",
            Self::TvOther => "2008000",
            Self::Movies => "3000000",
            Self::MoviesHD => "3001000",
            Self::MoviesSD => "3002000",
            Self::MoviesUHD => "3003000",
            Self::MoviesDVD => "3004000",
            Self::MoviesForeign => "3005000",
            Self::MoviesBollywood => "3006000",
            Self::Movies3D => "3007000",
            Self::MoviesOther => "3008000",
            Self::PC => "4000000",
            Self::PCGames => "4001000",
            Self::PCSoftware => "4002000",
            Self::PCMac => "4003000",
            Self::PCUnix => "4004000",
            Self::XXX => "5000000",
            Self::XXXVideo => "5001000",
            Self::XXXImageSet => "5002000",
            Self::XXXGames => "5003000",
            Self::XXXHentai => "5004000",
            Self::XXXOther => "5005000",
            Self::Anime => "6000000",
            Self::AnimeSubbed => "6001000",
            Self::AnimeDubbed => "6002000",
            Self::AnimeDualAudio => "6003000",
            Self::AnimeRaw => "6004000",
            Self::AnimeMusicVideo => "6005000",
            Self::AnimeLiterature => "6006000",
            Self::AnimeMusic => "6007000",
            Self::AnimeNonEnglishTranslated => "6008000",
            Self::Console => "7000000",
            Self::ConsolePS4 => "7001000",
            Self::ConsolePS3 => "7002000",
            Self::ConsolePS2 => "7003000",
            Self::ConsolePS1 => "7004000",
            Self::ConsolePSVita => "7005000",
            Self::ConsolePSP => "7006000",
            Self::ConsoleXbox360 => "7007000",
            Self::ConsoleXbox => "7008000",
            Self::ConsoleSwitch => "7009000",
            Self::ConsoleNDS => "7010000",
            Self::ConsoleWii => "7011000",
            Self::ConsoleWiiU => "7012000",
            Self::Console3DS => "7013000",
            Self::ConsoleGameCube => "7014000",
            Self::ConsoleOther => "7015000",
            Self::Mobile => "8000000",
            Self::MobileAndroid => "8001000",
            Self::MobileIOS => "8002000",
            Self::MobileOther => "8003000",
            Self::Books => "9000000",
            Self::BooksEbooks => "9001000",
            Self::BooksComics => "9002000",
            Self::BooksMagazines => "9003000",
            Self::BooksTechnical => "9004000",
            Self::BooksOther => "9005000",
            Self::Other => "10000000",
            Self::OtherMisc => "10001000",
        }
    }

    pub fn all_categories() -> Vec<String> {
        [
            Self::AllCategories,
            Self::Audio,
            Self::AudioMp3,
            Self::AudioLossless,
            Self::AudioAudioBook,
            Self::AudioVideo,
            Self::AudioRadio,
            Self::AudioOther,
            Self::Tv,
            Self::TvHD,
            Self::TvSD,
            Self::TvUHD,
            Self::TvDocumentary,
            Self::TvForeign,
            Self::TvSport,
            Self::TvCartoon,
            Self::TvOther,
            Self::Movies,
            Self::MoviesHD,
            Self::MoviesSD,
            Self::MoviesUHD,
            Self::MoviesDVD,
            Self::MoviesForeign,
            Self::MoviesBollywood,
            Self::Movies3D,
            Self::MoviesOther,
            Self::PC,
            Self::PCGames,
            Self::PCSoftware,
            Self::PCMac,
            Self::PCUnix,
            Self::XXX,
            Self::XXXVideo,
            Self::XXXImageSet,
            Self::XXXGames,
            Self::XXXHentai,
            Self::XXXOther,
            Self::Anime,
            Self::AnimeSubbed,
            Self::AnimeDubbed,
            Self::AnimeDualAudio,
            Self::AnimeRaw,
            Self::AnimeMusicVideo,
            Self::AnimeLiterature,
            Self::AnimeMusic,
            Self::AnimeNonEnglishTranslated,
            Self::Console,
            Self::ConsolePS4,
            Self::ConsolePS3,
            Self::ConsolePS2,
            Self::ConsolePS1,
            Self::ConsolePSVita,
            Self::ConsolePSP,
            Self::ConsoleXbox360,
            Self::ConsoleXbox,
            Self::ConsoleSwitch,
            Self::ConsoleNDS,
            Self::ConsoleWii,
            Self::ConsoleWiiU,
            Self::Console3DS,
            Self::ConsoleGameCube,
            Self::ConsoleOther,
            Self::Mobile,
            Self::MobileAndroid,
            Self::MobileIOS,
            Self::MobileOther,
            Self::Books,
            Self::BooksEbooks,
            Self::BooksComics,
            Self::BooksMagazines,
            Self::BooksTechnical,
            Self::BooksOther,
            Self::Other,
            Self::OtherMisc,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &KnabenDatabaseCategories,
        sorting: &KnabenDatabaseSortings,
        page_number: &i64,
    ) -> String {
        // https://knaben.org/search/naruto/6000000/2/seeders

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://knaben.org";
        let path = "search";
        let sorting = sorting.to_value();

        format!(
            "{}/{}/{}/{}/{}/{}",
            root_url,
            path,
            torrent_name,
            category.to_value(),
            page_number,
            sorting
        )
    }

    // Scraping
    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // checking if torrents are available or not.
        if html_response.contains("Total hits: 0") {
            return Err(anyhow!("No torrents found with the specified name."));
        }

        // Selectors
        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!(format!("Error parsing table body selector: {}", e)))?;

        let table_row_selector = Selector::parse("tr.text-nowrap.border-start")
            .map_err(|e| anyhow!(format!("Error parsing table row selector: {}", e)))?;

        let table_data_selector = Selector::parse("td")
            .map_err(|e| anyhow!(format!("Error parsing table data selector: {}", e)))?;

        let title_anchor_selector = Selector::parse("td:nth-child(2) > a:nth-child(1)")
            .map_err(|e| anyhow!(format!("Error parsing title anchor selector: {}", e)))?;

        let next_page_link_selector = Selector::parse("a#nextPage")
            .map_err(|e| anyhow!(format!("Error parsing next page link selector: {}", e)))?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        // extracting next page number
        let next_page_num: Option<i64> = document
            .select(&next_page_link_selector)
            .next()
            .and_then(|element| element.attr("href"))
            .and_then(|href| {
                href.split('/').nth(4) // Get the 5th item (index 4)
            })
            .and_then(|page_segment| page_segment.parse::<i64>().ok());

        if let Some(table_body) = document.select(&table_body_selector).next() {
            for table_row in table_body.select(&table_row_selector) {
                let table_row_data: Vec<ElementRef> =
                    table_row.select(&table_data_selector).collect();

                if table_row_data.len() < 7 {
                    // Skipping rows that don't have the expected 7 columns
                    continue;
                }

                // extracting Info Hash
                let info_hash = match table_row.attr("data-id") {
                    Some(i_h) => {
                        // skipping torrent if it has Invalid info hash
                        if i_h.len() != 40 {
                            continue;
                        }
                        // skipping torrent if it has Invalid info hash (non-hex characters)
                        if !i_h.chars().all(|c| c.is_ascii_hexdigit()) {
                            continue;
                        }
                        i_h.to_lowercase()
                    }
                    None => {
                        eprintln!("Skipping row: Missing data-id (info_hash).");
                        continue;
                    }
                };

                // extracting torrent name and magnet link
                let (name, magnet) =
                    if let Some(title_anchor) = table_row.select(&title_anchor_selector).next() {
                        let name = title_anchor
                            .attr("title")
                            .map(|a| a.to_string())
                            .unwrap_or_else(|| {
                                title_anchor.text().collect::<String>().trim().to_string()
                            });

                        let magnet = match title_anchor.attr("href") {
                            Some(magnet) => magnet.to_string(),
                            None => continue, // skipping this torrent if magnet not
                        };
                        (name, magnet)
                    } else {
                        ("N/A".to_string(), "N/A".to_string())
                    };

                // skipping if there is no magnet_link..
                if magnet.is_empty() || !magnet.starts_with("magnet:") {
                    continue;
                }

                // size
                let size = table_row_data[2]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();

                // date
                let date = table_row_data[3]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();

                // seeders
                let seeders = table_row_data[4]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();

                // leechers
                let leechers = table_row_data[5]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();

                // Downloads
                let total_downloads = "N/A".to_string();

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
        }

        Ok((all_torrents, next_page_num))
    }
}

impl fmt::Display for KnabenDatabaseCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Audio => write!(f, "Audio"),
            Self::AudioMp3 => write!(f, "Audio Mp3"),
            Self::AudioLossless => write!(f, "Audio Lossless"),
            Self::AudioAudioBook => write!(f, "AudioBook"),
            Self::AudioVideo => write!(f, "Audio Video"),
            Self::AudioRadio => write!(f, "Audio Radio"),
            Self::AudioOther => write!(f, "Audio Other"),
            Self::Tv => write!(f, "Tv"),
            Self::TvHD => write!(f, "HD Tv"),
            Self::TvSD => write!(f, "SD Tv"),
            Self::TvUHD => write!(f, "UHD Tv"),
            Self::TvDocumentary => write!(f, "Tv Documentary"),
            Self::TvForeign => write!(f, "Foreign Tv"),
            Self::TvSport => write!(f, "Sport Tv"),
            Self::TvCartoon => write!(f, "Cartoon Tv"),
            Self::TvOther => write!(f, "Other Tv"),
            Self::Movies => write!(f, "Movies"),
            Self::MoviesHD => write!(f, "HD Movies"),
            Self::MoviesSD => write!(f, "SD Movies"),
            Self::MoviesUHD => write!(f, "UHD Movies"),
            Self::MoviesDVD => write!(f, "DVD Movies"),
            Self::MoviesForeign => write!(f, "Foreign Movies"),
            Self::MoviesBollywood => write!(f, "Bollywood Movies"),
            Self::Movies3D => write!(f, "3D Movies"),
            Self::MoviesOther => write!(f, "Other Movies"),
            Self::PC => write!(f, "PC"),
            Self::PCGames => write!(f, "PC Games"),
            Self::PCSoftware => write!(f, "PC Software"),
            Self::PCMac => write!(f, "PC Mac"),
            Self::PCUnix => write!(f, "PC Unix"),
            Self::XXX => write!(f, "XXX"),
            Self::XXXVideo => write!(f, "XXX Video"),
            Self::XXXImageSet => write!(f, "XXX ImageSet"),
            Self::XXXGames => write!(f, "XXX Games"),
            Self::XXXHentai => write!(f, "XXX Hentai"),
            Self::XXXOther => write!(f, "Other XXX"),
            Self::Anime => write!(f, "Anime"),
            Self::AnimeSubbed => write!(f, "Subbed Anime"),
            Self::AnimeDubbed => write!(f, "Dubbed Anime"),
            Self::AnimeDualAudio => write!(f, "Dual Audio Anime"),
            Self::AnimeRaw => write!(f, "Raw Anime"),
            Self::AnimeMusicVideo => write!(f, "Anime Music Video"),
            Self::AnimeLiterature => write!(f, "Anime Literature"),
            Self::AnimeMusic => write!(f, "Anime Music"),
            Self::AnimeNonEnglishTranslated => write!(f, "Non English Translated Anime"),
            Self::Console => write!(f, "Console"),
            Self::ConsolePS4 => write!(f, "PS4"),
            Self::ConsolePS3 => write!(f, "PS3"),
            Self::ConsolePS2 => write!(f, "PS2"),
            Self::ConsolePS1 => write!(f, "PS1"),
            Self::ConsolePSVita => write!(f, "PS Vita"),
            Self::ConsolePSP => write!(f, "PSP"),
            Self::ConsoleXbox360 => write!(f, "Xbox360"),
            Self::ConsoleXbox => write!(f, "Xbox"),
            Self::ConsoleSwitch => write!(f, "Switch"),
            Self::ConsoleNDS => write!(f, "Nintendo Switch"),
            Self::ConsoleWii => write!(f, "Nintendo Wii"),
            Self::ConsoleWiiU => write!(f, "Nintendo WiiU"),
            Self::Console3DS => write!(f, "Nintendo 3DS"),
            Self::ConsoleGameCube => write!(f, "Nintendo GameCube"),
            Self::ConsoleOther => write!(f, "Other Console"),
            Self::Mobile => write!(f, "Mobile"),
            Self::MobileAndroid => write!(f, "Android Mobile"),
            Self::MobileIOS => write!(f, "IOS Mobile"),
            Self::MobileOther => write!(f, "Other Mobile"),
            Self::Books => write!(f, "Books"),
            Self::BooksEbooks => write!(f, "Ebooks"),
            Self::BooksComics => write!(f, "Comics"),
            Self::BooksMagazines => write!(f, "Magazines"),
            Self::BooksTechnical => write!(f, "Technical Books"),
            Self::BooksOther => write!(f, "Other Books"),
            Self::Other => write!(f, "Other"),
            Self::OtherMisc => write!(f, "Other Misc"),
        }
    }
}

pub enum KnabenDatabaseSortings {
    BySize,
    ByDate,
    BySeeders,
    ByLeechers,
}

impl KnabenDatabaseSortings {
    pub fn to_sorting(sorting_str: &str) -> Self {
        match sorting_str {
            "By Size" => Self::BySize,
            "By Date" => Self::ByDate,
            "By Seeders" => Self::BySeeders,
            "By Leechers" => Self::ByLeechers,
            &_ => Self::BySeeders,
        }
    }

    pub fn to_value(&self) -> &str {
        match *self {
            Self::BySize => "bytes",
            Self::ByDate => "date",
            Self::BySeeders => "seeders",
            Self::ByLeechers => "peers",
        }
    }

    pub fn all_sortings() -> Vec<String> {
        [
            Self::BySize,
            Self::ByDate,
            Self::BySeeders,
            Self::ByLeechers,
        ]
        .iter()
        .map(|sorting| sorting.to_string())
        .collect()
    }
}

impl fmt::Display for KnabenDatabaseSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::BySize => write!(f, "By Size"),
            Self::ByDate => write!(f, "By Date"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}
