use core::fmt;
use std::error::Error;

use scraper::{ElementRef, Html, Selector};
use ureq::{Body, http::Response};

use crate::{sources::QueryOptions, torrent::Torrent, trackers::get_trackers};

#[derive(Debug)]
pub enum LimeTorrentsCategories {
    AllCategories, // 'All' category on website
    Anime,
    Softwares, // 'Applications' category on website
    Games,
    Movies,
    Music,
    Tv,
    Other,
}

impl LimeTorrentsCategories {
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
            "Anime" => Self::Anime,
            "Softwares" => Self::Softwares,
            "Games" => Self::Games,
            "Movies" => Self::Movies,
            "Music" => Self::Music,
            "Tv" => Self::Tv,
            "Other" => Self::Other,
            &_ => Self::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            Self::AllCategories => "all".to_string(),
            Self::Anime => "anime".to_string(),
            Self::Softwares => "applications".to_string(),
            Self::Games => "games".to_string(),
            Self::Movies => "movies".to_string(),
            Self::Music => "music".to_string(),
            Self::Tv => "tv".to_string(),
            Self::Other => "other".to_string(),
        }
    }

    pub fn all_categories() -> Vec<String> {
        [
            Self::AllCategories,
            Self::Anime,
            Self::Softwares,
            Self::Games,
            Self::Movies,
            Self::Music,
            Self::Tv,
            Self::Other,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &LimeTorrentsCategories,
        sorting: &LimeTorrentsSortings,
        page_number: &i64,
    ) -> String {
        // https://www.limetorrents.lol/search/all/fate/seeds/1/
        // https://www.limetorrents.fun/search/all/fate/seeds/1/

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://www.limetorrents.lol";
        let path = "search";
        let category = category.category_to_value();
        let sorting = sorting.sorting_to_value();

        format!(
            "{}/{}/{}/{}/{}/{}/",
            root_url, path, category, torrent_name, sorting, page_number
        )

        //  "{}/{}/{}/{}/{}/{}/" => works on both normal and proxy mode.
        //  "{}/{}/{}/{}/{}/{}" => works only in normal mode. it is giving crlf errors like
        // protocol: chunk expected crlf as next character
        // tested on Tor SOCKS5 Proxy
    }

    // Scraping
    pub fn scrape_and_parse(
        mut response: Response<Body>,
    ) -> Result<(Vec<Torrent>, Option<i64>), Box<dyn Error>> {
        // Scraping
        let html_response = response.body_mut().read_to_string()?;
        let document = Html::parse_document(&html_response);

        // selectors
        let div_selector = Selector::parse(r#"div[id="content"]"#)?;
        let table_selector = Selector::parse(r#"table[class="table2"]"#)?;
        let table_body_selector = Selector::parse("tbody")?;
        // select only rows that have torrent data,
        let table_row_selector = Selector::parse("tr[bgcolor]")?;

        let table_data_selector = Selector::parse("td")?;
        let anchor_tag_selector = Selector::parse("a")?;
        let active_page_selector = Selector::parse("span.active")?;

        let torrent_name_and_magnet_div_selector = Selector::parse("div.tt-name")?;

        // Vector of Torrent to Store all Torrents
        let mut all_torrents: Vec<Torrent> = Vec::new();

        let div = document.select(&div_selector).next().unwrap();
        let table = div.select(&table_selector).next().unwrap();
        let table_body = table.select(&table_body_selector).next().unwrap();

        // Active Page Number
        let next_page_num: Option<i64> =
            if let Some(active_page_element) = document.select(&active_page_selector).next() {
                let current_page_num = active_page_element
                    .text()
                    .collect::<String>()
                    .parse::<i64>()?;
                Some(current_page_num + 1)
            } else {
                // No active pagination element found, so no next page.
                None
            };

        for table_row in table_body.select(&table_row_selector) {
            let table_row_data: Vec<ElementRef> = table_row.select(&table_data_selector).collect();

            if table_row_data.len() < 6 {
                // Skip rows that don't have the expected structure
                continue;
            }

            // Extracting Torrent Name & Magnet link from first td
            let name_magnet_div = table_row_data[0]
                .select(&torrent_name_and_magnet_div_selector)
                .next();
            let anchor_tags: Vec<ElementRef> = name_magnet_div
                .into_iter()
                .flat_map(|div| div.select(&anchor_tag_selector))
                .collect();

            // Magnet Link
            // There is not magnet link but there is a hyprlink of .torrent file
            // and that .torrent file has info_hash in it's name
            // so using that info_hash to create magnet link.
            let torrent_file_hyperlink = anchor_tags
                .first()
                .and_then(|a| a.attr("href"))
                .map_or("N/A".to_string(), |s| s.to_string());

            // extracting info_hash.
            let info_hash_start =
                torrent_file_hyperlink.trim_start_matches("http://itorrents.net/torrent/");
            // finding index for .torrent
            let info_hash_end_index = info_hash_start.find(".torrent").unwrap();
            // actual info hash
            let info_hash = &info_hash_start[..info_hash_end_index].to_lowercase();

            // Extracting Display Name
            let disply_name_start_index = torrent_file_hyperlink.find("title=").unwrap();
            let disply_name = &torrent_file_hyperlink[disply_name_start_index + "title=".len()..];

            // now creating magnet link from info hash and display name.
            let magnet_link_prefix = String::from("magnet:?xt=urn:btih:");
            let mut magnet = magnet_link_prefix + info_hash + "&dn=" + disply_name;

            // adding extra trackers
            magnet.push_str(get_trackers()?.as_str());

            // using display name as Torrent Name

            // date and category are appended.
            let date_category_text = table_row_data[1]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // extracting date
            // The format is "1 Year+ - in Anime." - we can split by ' - in '
            let date = if let Some(parts) = date_category_text.split_once(" - in ") {
                // If successful, use the first part (the date)
                parts.0.trim().to_string()
            } else {
                // If unable to split (or no match), use the original text as a fallback
                // Fallback to date category appended text
                date_category_text
            };

            // torrent size
            let size = table_row_data[2]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // Seeders
            let seeders = table_row_data[3]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // Leechers
            let leechers = table_row_data[4]
                .text()
                .collect::<String>()
                .trim()
                .to_string();

            // total downloads
            // this source doesn't provide total downloads number.
            let total_downloads = "N/A".to_string();

            let torrent = Torrent {
                info_hash: info_hash.to_string(),
                name: disply_name.to_string(),
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

impl fmt::Display for LimeTorrentsCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Anime => write!(f, "Anime"),
            Self::Softwares => write!(f, "Softwares"),
            Self::Games => write!(f, "Games"),
            Self::Movies => write!(f, "Movies"),
            Self::Music => write!(f, "Music"),
            Self::Tv => write!(f, "Tv"),
            Self::Other => write!(f, "Other"),
        }
    }
}

pub enum LimeTorrentsSortings {
    ByDate,
    BySize,
    BySeeders,
    ByLeechers,
}

impl LimeTorrentsSortings {
    pub fn to_sorting(sorting_str: &str) -> Self {
        match sorting_str {
            "By Date" => Self::ByDate,
            "By Size" => Self::BySize,
            "By Seeders" => Self::BySeeders,
            "By Leechers" => Self::ByLeechers,
            _ => Self::BySeeders,
        }
    }

    pub fn sorting_to_value(&self) -> String {
        match *self {
            Self::ByDate => "date".to_string(),
            Self::BySize => "size".to_string(),
            Self::BySeeders => "seeds".to_string(),
            Self::ByLeechers => "leechs".to_string(),
        }
    }

    pub fn all_limetorrents_sortings() -> Vec<String> {
        [
            Self::ByDate,
            Self::BySize,
            Self::BySeeders,
            Self::ByLeechers,
        ]
        .iter()
        .map(|sorting| sorting.to_string())
        .collect()
    }
}

impl fmt::Display for LimeTorrentsSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ByDate => write!(f, "By Date"),
            Self::BySize => write!(f, "By Size"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}
