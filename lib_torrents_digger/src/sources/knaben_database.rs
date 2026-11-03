// Knaben Database

use anyhow::{Result, anyhow};
use core::fmt;
use regex::Regex;
use scraper::{ElementRef, Html, Selector};
use serde::Deserialize;
use ureq::{Body, ResponseExt, http::Response};

use crate::{
    prepare_info_hash,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
};

fn format_bytes(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;
    const TB: u64 = GB * 1024;

    if bytes >= TB {
        format!("{:.2} TB", bytes as f64 / TB as f64)
    } else if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} B", bytes)
    }
}

#[derive(Debug, Deserialize)]
struct KnabenResponse {
    #[serde(default)]
    hits: Vec<KnabenHit>,
    #[serde(default)]
    total: Option<KnabenTotal>,
}

#[derive(Debug, Deserialize)]
struct KnabenTotal {
    #[serde(default)]
    value: Option<i64>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct KnabenHit {
    title: Option<String>,
    hash: Option<String>,
    magnet_url: Option<String>,
    bytes: Option<u64>,
    date: Option<String>,
    seeders: Option<i64>,
    peers: Option<i64>,
    live_seeders: Option<i64>,
    live_peers: Option<i64>,
    grabs: Option<i64>,
    details: Option<String>,
    link: Option<String>,
}

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
            filters: false,
            sortings: true,
            sorting_orders: true,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [KnabenDatabaseCategories] = &[
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
    ];

    pub fn from_index(index: usize) -> Option<&'static KnabenDatabaseCategories> {
        Self::ALL_VARIANTS.get(index)
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
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &KnabenDatabaseCategories,
        sorting: &KnabenDatabaseSortings,
        sorting_order: &KnabenDatabaseSortingOrders,
        page_number: &i64,
    ) -> String {
        let base_url = "https://api.knaben.org";
        let trimmed_name = torrent_name.trim();

        let endpoint = if trimmed_name.is_empty() {
            "v2/browse".to_string()
        } else {
            format!("v2/search?q={}", urlencoding::encode(trimmed_name))
        };

        let mut query_params = Vec::new();

        let cat_val = category.to_value();
        if cat_val != "000000000" && cat_val != "0" {
            query_params.push(format!("c={}", cat_val));
        }

        if cat_val.starts_with('5') {
            query_params.push("xxx".to_string());
        }

        query_params.push(format!("o={}", sorting.to_value()));
        query_params.push(format!("d={}", sorting_order.sorting_order_to_value()));

        let page = (*page_number).max(1);
        let size: i64 = 100;
        let from = (page - 1) * size;
        query_params.push(format!("f={}", from));
        query_params.push(format!("s={}", size));

        let query_string = query_params.join("&");
        if endpoint.contains('?') {
            format!("{}/{}&{}", base_url, endpoint, query_string)
        } else {
            format!("{}/{}?{}", base_url, endpoint, query_string)
        }
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let uri = response.get_uri().to_string();
        let body = response.body_mut().read_to_string()?;
        let trimmed = body.trim();

        if trimmed.starts_with('{') {
            Self::parse_json(&body, Some(&uri))
        } else if trimmed.contains("<rss")
            || trimmed.contains("<?xml")
            || trimmed.contains("<item>")
        {
            Self::parse_rss(&body)
        } else {
            Self::parse_html(&body)
        }
    }

    pub fn parse_json(json: &str, uri: Option<&str>) -> Result<(Vec<Torrent>, Pagination)> {
        let resp: KnabenResponse = serde_json::from_str(json)
            .map_err(|e| anyhow!("Failed to parse Knaben API v2 JSON: {}", e))?;

        if resp.hits.is_empty() {
            return Err(anyhow!("No torrents found with the specified name."));
        }

        let mut all_torrents: Vec<Torrent> = Vec::with_capacity(resp.hits.len());

        for hit in resp.hits {
            let name = hit.title.unwrap_or_default();
            let magnet = hit.magnet_url.unwrap_or_default();
            let info_hash = hit
                .hash
                .map(|h| h.to_lowercase())
                .or_else(|| prepare_info_hash(&magnet).ok())
                .unwrap_or_default();

            let size = hit.bytes.map(format_bytes).unwrap_or_default();
            let date = hit
                .date
                .as_deref()
                .map(|d| d.split('T').next().unwrap_or(d).to_string())
                .unwrap_or_default();

            let seeders = hit
                .live_seeders
                .or(hit.seeders)
                .map(|s| s.to_string())
                .unwrap_or_default();
            let leechers = hit
                .live_peers
                .or(hit.peers)
                .map(|p| p.to_string())
                .unwrap_or_default();
            let total_downloads = hit.grabs.map(|g| g.to_string()).unwrap_or_default();
            let source_url = hit.details.or(hit.link);

            all_torrents.push(Torrent {
                info_hash,
                name,
                magnet,
                size,
                date,
                seeders,
                leechers,
                total_downloads,
                source_url,
            });
        }

        let mut from: i64 = 0;
        let mut size: i64 = 100;
        if let Some(uri_str) = uri {
            if let Some(query) = uri_str.split('?').nth(1) {
                for pair in query.split('&') {
                    let mut parts = pair.split('=');
                    let key = parts.next().unwrap_or("");
                    let val = parts.next().unwrap_or("");
                    if key == "f" {
                        if let Ok(v) = val.parse::<i64>() {
                            from = v;
                        }
                    } else if key == "s" {
                        if let Ok(v) = val.parse::<i64>() {
                            size = v.max(1);
                        }
                    }
                }
            }
        }

        let current_page = (from / size) + 1;
        let previous_page = if current_page > 1 {
            Some((current_page - 1) as i32)
        } else {
            None
        };

        let total_hits = resp.total.and_then(|t| t.value).unwrap_or(0);
        let next_page = if total_hits > from + all_torrents.len() as i64 {
            Some((current_page + 1) as i32)
        } else {
            None
        };

        Ok((
            all_torrents,
            Pagination {
                current_page: Some(current_page as i32),
                previous_page,
                next_page,
            },
        ))
    }

    pub fn parse_rss(xml: &str) -> Result<(Vec<Torrent>, Pagination)> {
        let mut all_torrents: Vec<Torrent> = Vec::new();
        let re_item = Regex::new(r"(?s)<item>(.*?)</item>")?;
        let re_title = Regex::new(r"(?s)<title>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</title>")?;
        let re_link = Regex::new(r"(?s)<link>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</link>")?;
        let re_pub_date = Regex::new(r"(?s)<pubDate>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</pubDate>")?;
        let re_size = Regex::new(r"Size:\s*([0-9.]+\s*[KMGT]?B)")?;
        let re_source = Regex::new(r#"Source:\s*<a\s+href="([^"]+)""#)?;
        let re_magnet = Regex::new(r#"href="(magnet:\?[^"]+)""#)?;

        for cap in re_item.captures_iter(xml) {
            let item_xml = &cap[1];

            let name = re_title
                .captures(item_xml)
                .map(|c| c[1].trim().to_string())
                .unwrap_or_default();

            let link = re_link
                .captures(item_xml)
                .map(|c| c[1].trim().to_string())
                .unwrap_or_default();

            let mut magnet = String::new();
            let mut source_url = None;

            if link.starts_with("magnet:") {
                magnet = link;
            } else if !link.is_empty() {
                source_url = Some(link);
            }

            if magnet.is_empty() {
                if let Some(m_cap) = re_magnet.captures(item_xml) {
                    magnet = m_cap[1].to_string();
                }
            }

            if source_url.is_none() {
                if let Some(s_cap) = re_source.captures(item_xml) {
                    source_url = Some(s_cap[1].to_string());
                }
            }

            let size = re_size
                .captures(item_xml)
                .map(|c| c[1].trim().to_string())
                .unwrap_or_default();

            let date = re_pub_date
                .captures(item_xml)
                .map(|c| c[1].trim().to_string())
                .unwrap_or_default();

            let info_hash = prepare_info_hash(&magnet).unwrap_or_default();

            all_torrents.push(Torrent {
                info_hash,
                name,
                magnet,
                size,
                date,
                seeders: String::new(),
                leechers: String::new(),
                total_downloads: String::new(),
                source_url,
            });
        }

        if all_torrents.is_empty() {
            return Err(anyhow!("No torrents found in RSS feed."));
        }

        Ok((
            all_torrents,
            Pagination {
                current_page: Some(1),
                previous_page: None,
                next_page: None,
            },
        ))
    }

    // Scraping fallback
    pub fn parse_html(html_response: &str) -> Result<(Vec<Torrent>, Pagination)> {
        let document = Html::parse_document(html_response);

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

        let pagination_container_selector = Selector::parse("div.pageNumbers")
            .map_err(|e| anyhow!(format!("Error parsing pagination selector: {}", e)))?;

        let active_page_selector = Selector::parse("a.active")
            .map_err(|e| anyhow!(format!("Error parsing active page selector: {}", e)))?;

        let prev_page_selector = Selector::parse("a#prevPage")
            .map_err(|e| anyhow!(format!("Error parsing previous page selector: {}", e)))?;

        let next_page_selector = Selector::parse("a#nextPage")
            .map_err(|e| anyhow!(format!("Error parsing next page selector: {}", e)))?;

        let anchor_tag_selector = Selector::parse("a")
            .map_err(|e| anyhow!(format!("Error parsing anchor tag selector: {}", e)))?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let mut pagination = Pagination::new();

        // Target only the first pagination container found.
        // there are 2 pagination container, btw :)
        if let Some(nav) = document.select(&pagination_container_selector).next() {
            // for Current Page
            if let Some(active_el) = nav.select(&active_page_selector).next()
                && let Ok(curr) = active_el.text().collect::<String>().trim().parse::<i32>()
            {
                pagination.current_page = Some(curr);

                // for Previous Page
                // (Must exist & be less than current)
                if let Some(prev_el) = nav.select(&prev_page_selector).next()
                    && let Some(href) = prev_el.attr("href")
                    && let Some(page_val) =
                        href.split('/').nth(4).and_then(|s| s.parse::<i32>().ok())
                    && page_val < curr
                {
                    pagination.previous_page = Some(page_val);
                }

                // for Next Page
                // Must exist & be greater than current
                if let Some(next_el) = nav.select(&next_page_selector).next()
                    && let Some(href) = next_el.attr("href")
                    && let Some(page_val) =
                        href.split('/').nth(4).and_then(|s| s.parse::<i32>().ok())
                    && page_val > curr
                {
                    pagination.next_page = Some(page_val);
                }
            }
        }

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
                        prepare_info_hash(i_h)?
                    }
                    None => {
                        //  Skipping row: Missing data-id (info_hash)
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

                // source
                let mut source_url: Option<String> = None;
                if let Some(anchor) = table_row_data[6].select(&anchor_tag_selector).next() {
                    if let Some(source_link) = anchor.attr("href") {
                        source_url = Some(source_link.into());
                    }
                } else {
                    source_url = None;
                }

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
                    source_url,
                };
                all_torrents.push(torrent);
            }
        }

        Ok((all_torrents, pagination))
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
    const ALL_VARIANTS: &'static [KnabenDatabaseSortings] = &[
        Self::BySize,
        Self::ByDate,
        Self::BySeeders,
        Self::ByLeechers,
    ];

    pub fn from_index(index: usize) -> Option<&'static KnabenDatabaseSortings> {
        Self::ALL_VARIANTS.get(index)
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
        Self::ALL_VARIANTS
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

pub enum KnabenDatabaseSortingOrders {
    Ascending,
    Descending,
}

impl KnabenDatabaseSortingOrders {
    const ALL_VARIANTS: &'static [KnabenDatabaseSortingOrders] =
        &[Self::Ascending, Self::Descending];

    pub fn from_index(index: usize) -> Option<&'static KnabenDatabaseSortingOrders> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_order_to_value(&self) -> &str {
        match *self {
            Self::Ascending => "asc",
            Self::Descending => "desc",
        }
    }

    pub fn all_knaben_database_sorting_orders() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for KnabenDatabaseSortingOrders {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Ascending => write!(f, "Ascending Order"),
            Self::Descending => write!(f, "Descending Order"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_knaben_search() {
        let url = KnabenDatabaseCategories::request_url_builder(
            "ubuntu linux",
            &KnabenDatabaseCategories::PCUnix,
            &KnabenDatabaseSortings::BySeeders,
            &KnabenDatabaseSortingOrders::Descending,
            &2,
        );
        assert_eq!(
            url,
            "https://api.knaben.org/v2/search?q=ubuntu%20linux&c=4004000&o=seeders&d=desc&f=100&s=100"
        );
    }

    #[test]
    fn test_request_builder_knaben_browse() {
        let url = KnabenDatabaseCategories::request_url_builder(
            "",
            &KnabenDatabaseCategories::MoviesHD,
            &KnabenDatabaseSortings::ByDate,
            &KnabenDatabaseSortingOrders::Descending,
            &1,
        );
        assert_eq!(
            url,
            "https://api.knaben.org/v2/browse?c=3001000&o=date&d=desc&f=0&s=100"
        );
    }

    #[test]
    fn test_request_builder_knaben_xxx() {
        let url = KnabenDatabaseCategories::request_url_builder(
            "hentai",
            &KnabenDatabaseCategories::XXXHentai,
            &KnabenDatabaseSortings::BySize,
            &KnabenDatabaseSortingOrders::Ascending,
            &1,
        );
        assert_eq!(
            url,
            "https://api.knaben.org/v2/search?q=hentai&c=5004000&xxx&o=bytes&d=asc&f=0&s=100"
        );
    }

    #[test]
    fn test_parse_json_knaben_v2() {
        let json = r#"{
            "hits": [
                {
                    "title": "Ubuntu 10.10 amd64",
                    "hash": "4AF6FB7CBFB8771F98A92302693B31E863B89D3E",
                    "magnetUrl": "magnet:?xt=urn:btih:4AF6FB7CBFB8771F98A92302693B31E863B89D3E&dn=Ubuntu",
                    "bytes": 728749834,
                    "date": "2010-10-16T23:00:00+00:00",
                    "seeders": 12,
                    "peers": 4,
                    "grabs": 55,
                    "details": "https://knaben.xyz/details/123"
                }
            ],
            "total": {
                "value": 150
            }
        }"#;

        let uri = "https://api.knaben.org/v2/search?q=ubuntu&f=0&s=100";
        let (torrents, pagination) =
            KnabenDatabaseCategories::parse_json(json, Some(uri)).unwrap();
        assert_eq!(torrents.len(), 1);
        assert_eq!(torrents[0].name, "Ubuntu 10.10 amd64");
        assert_eq!(
            torrents[0].info_hash,
            "4af6fb7cbfb8771f98a92302693b31e863b89d3e"
        );
        assert_eq!(torrents[0].seeders, "12");
        assert_eq!(torrents[0].leechers, "4");
        assert_eq!(torrents[0].total_downloads, "55");
        assert_eq!(torrents[0].date, "2010-10-16");
        assert_eq!(
            torrents[0].source_url.as_deref(),
            Some("https://knaben.xyz/details/123")
        );
        assert_eq!(pagination.current_page, Some(1));
        assert_eq!(pagination.next_page, Some(2));
    }

    #[test]
    fn test_parse_rss_knaben() {
        let xml = r#"<?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title><![CDATA[Test Movie (2026) 1080p]]></title>
                    <link><![CDATA[magnet:?xt=urn:btih:0F0BB60CE7F22F4DB63B470F6F1D79C006920289&dn=Test]]></link>
                    <description><![CDATA[
                        Source: <a href="https://1337x.to/torrent/123/">https://1337x.to/torrent/123/</a><br />
                        Size: 3.82 GB<br />
                    ]]></description>
                    <pubDate>Tue, 03 Nov 2026 15:23:00 +0000</pubDate>
                </item>
            </channel>
        </rss>"#;

        let (torrents, pagination) = KnabenDatabaseCategories::parse_rss(xml).unwrap();
        assert_eq!(torrents.len(), 1);
        assert_eq!(torrents[0].name, "Test Movie (2026) 1080p");
        assert_eq!(
            torrents[0].info_hash,
            "0f0bb60ce7f22f4db63b470f6f1d79c006920289"
        );
        assert_eq!(torrents[0].size, "3.82 GB");
        assert_eq!(torrents[0].date, "Tue, 03 Nov 2026 15:23:00 +0000");
        assert_eq!(
            torrents[0].source_url.as_deref(),
            Some("https://1337x.to/torrent/123/")
        );
        assert_eq!(pagination.current_page, Some(1));
    }
}
