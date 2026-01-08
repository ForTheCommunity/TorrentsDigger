use core::fmt;

use anyhow::{Result, anyhow};
use scraper::{ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    extract_info_hash_from_magnet,
    sources::{Pagination, QueryOptions},
    sync_request::send_request,
    torrent::Torrent,
};

#[derive(Debug)]
pub enum ThePirateBayCategories {
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

impl ThePirateBayCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: false,
            sortings: true,
            sorting_orders: true,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [ThePirateBayCategories] = &[
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

    pub fn from_index(index: usize) -> Option<&'static ThePirateBayCategories> {
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

    pub fn get_active_domain() -> Result<String> {
        // Proxies
        // Proxies Source -> https://piratebayproxy.info
        let tpb_proxies = [
            "https://thepiratebay11.com",
            "https://thepiratebay10.info",
            "https://thepiratebay7.com",
            "https://thepiratebay0.org",
            "https://thepiratebay10.xyz",
            "https://pirateproxylive.org",
            "https://thehiddenbay.com",
            "https://piratebay.live",
            "https://thepiratebay.zone",
            "https://tpb.party",
            "https://thepiratebay.party",
            "https://piratebay.party",
            "https://piratebayproxy.live",
            "https://thepiratebay.xyz",
            "https://pirate-proxy.thepiratebay.rocks",
            "https://thepiratebay10.org",
            "https://pirateproxy.live",
            "https://thepiratebay1.live",
            "https://thepiratebays.info",
            "https://thepiratebays.live",
            "https://thepiratebay1.top",
            "https://thepiratebay1.info",
            "https://thepiratebay.rocks",
            "https://thepiratebay.vet",
        ];

        let mut active_domain: &str = "https://pirateproxylive.org";
        for a_proxy in tpb_proxies {
            let html_response = send_request(a_proxy)?.body_mut().read_to_string()?;
            // checking if htnl_response contains proxy site url or not,,
            // if that url is present then this domain is active.
            // we can check other Texts/Strings also..
            if html_response.contains("https://piratebayproxy.info") {
                active_domain = a_proxy;
                break;
            } else {
                continue;
            }
        }
        Ok(active_domain.to_string())
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &ThePirateBayCategories,
        sorting: &ThePirateBaySortings,
        sorting_order: &ThePirateBaySortingOrders,
        page_number: &i64,
    ) -> Result<String> {
        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = Self::get_active_domain()?;
        let path = "search";
        let category = format!("{}", category.category_to_value());
        let mut sorting = sorting.sorting_to_value().parse::<u8>()?;
        if sorting_order == &ThePirateBaySortingOrders::Descending {
            sorting = sorting - sorting_order.sorting_order_to_value().parse::<u8>()?;
        }

        Ok(format!(
            "{}/{}/{}/{}/{}/{}",
            root_url, path, torrent_name, page_number, sorting, category
        ))
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        // Scraping
        let html_response = response
            .body_mut()
            .read_to_string()
            .map_err(|e| anyhow!(format!("Error reading response body: {}", e)))?;
        let document = Html::parse_document(&html_response);

        // Selectors
        let table_selector = Selector::parse(r#"table[id="searchResult"]"#)
            .map_err(|e| anyhow!(format!("Error parsing table selector: {}", e)))?;

        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!(format!("Error parsing tbody selector: {}", e)))?;

        let table_row_selector = Selector::parse("tr")
            .map_err(|e| anyhow!(format!("Error parsing tr selector: {}", e)))?;

        let table_data_selector = Selector::parse("td")
            .map_err(|e| anyhow!(format!("Error parsing td selector: {}", e)))?;

        let anchor_tag_selector = Selector::parse("a")
            .map_err(|e| anyhow!(format!("Error parsing a selector: {}", e)))?;

        let b_tag_selector = Selector::parse("b")
            .map_err(|e| anyhow!(format!("Error parsing b selector: {}", e)))?;

        let img_selector = Selector::parse("img")
            .map_err(|e| anyhow!(format!("Error parsing img selector: {}", e)))?;

        let table = document
            .select(&table_selector)
            .next()
            .ok_or_else(|| anyhow!("Didn't found Table..."))?;

        let table_body = table.select(&table_body_selector).next().ok_or_else(|| {
            anyhow!(
                // Table Body doesn't exists.
                // means there are no torrents with this name...
                "No torrents found with the specified name."
            )
        })?;

        let mut torrents_vec: Vec<Torrent> = Vec::new();
        let mut pagination = Pagination::new();

        // iterating over table rows.
        for a_table_row in table_body.select(&table_row_selector) {
            let table_data_vec: Vec<ElementRef> =
                a_table_row.select(&table_data_selector).collect();

            if table_data_vec.len() >= 7 {
                let name = table_data_vec[1]
                    .select(&anchor_tag_selector)
                    .next()
                    .ok_or_else(|| anyhow!("Didn't found Anchor Tag while extracting name.."))?
                    .inner_html()
                    .to_string();

                let date = table_data_vec[2]
                    .inner_html()
                    .to_string()
                    .replace("&nbsp;", " ")
                    // Torrents uploaded in last 1 hours are wrapped inside a Bold Tag.
                    // So Replacing those opening & ending tag with empty string.
                    // (easy fix)
                    .replace("<b>", "")
                    .replace("</b>", "");

                let magnet = table_data_vec[3]
                    .select(&anchor_tag_selector)
                    .next()
                    .ok_or_else(|| {
                        anyhow!("Didn't found any anchor tag while extracting magnet link.")
                    })?
                    .value()
                    .attr("href")
                    .ok_or_else(|| anyhow!("Magnet link not found in href..."))?
                    .to_string();

                let size = table_data_vec[4]
                    .inner_html()
                    .to_string()
                    .replace("&nbsp;", " ");

                let seeders = table_data_vec[5].inner_html().to_string();
                let leechers = table_data_vec[6].inner_html().to_string();

                let total_downloads = "N/A".to_string();

                let info_hash = extract_info_hash_from_magnet(&magnet);

                torrents_vec.push(Torrent {
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
            // this is a pagination row...
            else if let Some(td_element) = table_data_vec.get(0) {
                // extracting current page number
                // For current page, We look for the number inside the <b> tag
                if let Some(b_tag) = td_element.select(&b_tag_selector).next() {
                    if let Ok(curr) = b_tag.inner_html().parse::<i32>() {
                        pagination.current_page = Some(curr);
                    }
                }

                // predecting previous page and next page based on arrow images
                // calculating next/prev if we successfully found the current page
                if let Some(curr) = pagination.current_page {
                    for link in td_element.select(&anchor_tag_selector) {
                        if let Some(img) = link.select(&img_selector).next() {
                            let alt_text = img.value().attr("alt").unwrap_or("");

                            match alt_text {
                                "Previous" => {
                                    pagination.previous_page = Some(curr - 1);
                                }
                                "Next" => {
                                    pagination.next_page = Some(curr + 1);
                                }
                                _ => {}
                            }
                        }
                    }
                }
            }
        }

        Ok((torrents_vec, pagination))
    }
}

impl fmt::Display for ThePirateBayCategories {
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

pub enum ThePirateBaySortings {
    ByDate,
    BySize,
    BySeeders,
    ByLeechers,
}

impl ThePirateBaySortings {
    const ALL_VARIANTS: &'static [ThePirateBaySortings] = &[
        Self::ByDate,
        Self::BySize,
        Self::BySeeders,
        Self::ByLeechers,
    ];

    pub fn from_index(index: usize) -> Option<&'static ThePirateBaySortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_to_value(&self) -> &str {
        match *self {
            Self::ByDate => "4",
            Self::BySize => "6",
            Self::BySeeders => "8",
            Self::ByLeechers => "10",
        }
    }

    pub fn all_pirate_bay_sortings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for ThePirateBaySortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ByDate => write!(f, "By Date"),
            Self::BySize => write!(f, "By Size"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}

#[derive(PartialEq)]
pub enum ThePirateBaySortingOrders {
    Ascending,
    Descending,
}

impl ThePirateBaySortingOrders {
    const ALL_VARIANTS: &'static [ThePirateBaySortingOrders] = &[Self::Ascending, Self::Descending];

    pub fn from_index(index: usize) -> Option<&'static ThePirateBaySortingOrders> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_order_to_value(&self) -> &str {
        match *self {
            Self::Ascending => "0",
            Self::Descending => "1",
        }
    }

    pub fn all_pirate_bay_sorting_orders() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for ThePirateBaySortingOrders {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Ascending => write!(f, "Ascending Order"),
            Self::Descending => write!(f, "Descending Order"),
        }
    }
}
