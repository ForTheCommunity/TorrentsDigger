use crate::{sources::QueryOptions, torrent::Torrent, trackers::DefaultTrackers};
use anyhow::Result;
use chrono::{DateTime, Utc};
use core::fmt;
use serde::{Deserialize, Serialize};
use ureq::{Body, http::Response};

pub enum TorrentsCsvCategories {
    AllCategories,
}

impl TorrentsCsvCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: false,
            sortings: false,
            filters: false,
            pagination: true,
        }
    }
    pub fn to_category(text_category: &str) -> TorrentsCsvCategories {
        match text_category {
            "All Categories" => TorrentsCsvCategories::AllCategories,
            _ => TorrentsCsvCategories::AllCategories,
        }
    }

    pub fn all_categories() -> Vec<String> {
        [Self::AllCategories]
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn request_url_builder_torrents_csv(torrent_name: &str, next: &Option<i64>) -> String {
        // https://torrents-csv.com/service/search?q=[QUERY]&size=[NUMBER_OF_RESULTS]&after=[AFTER]
        // Size parameter is not working [Problem in Api]
        // https://torrents-csv.com/service/search?q=[QUERY]&after=[AFTER]

        // url encoding
        let torrent_name = urlencoding::encode(torrent_name).to_string();

        let root_url = "https://torrents-csv.com";
        // let results_size = 50;

        match next {
            Some(next) => {
                format!(
                    "{}/service/search?q={}&after={}",
                    root_url, torrent_name, next
                )
            }
            None => {
                format!("{}/service/search?q={}", root_url, torrent_name)
            }
        }
    }

    pub fn parse_response(mut response: Response<Body>) -> Result<(Vec<Torrent>, Option<i64>)> {
        let json_response_txt = response.body_mut().read_to_string()?;
        let json_root: JsonRoot = serde_json::from_str(&json_response_txt)?;
        let torrents: Vec<Torrent> = json_root
            .torrents
            .iter()
            .map(|td| td.to_torrent())
            .collect();
        let next_page = json_root.next;
        Ok((torrents, next_page))
    }
}

impl fmt::Display for TorrentsCsvCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TorrentsCsvCategories::AllCategories => write!(f, "All Categories"),
        }
    }
}

#[derive(Serialize, Deserialize, Debug)]
struct JsonRoot {
    torrents: Vec<JsonTorrentData>,
    next: Option<i64>,
}

#[derive(Serialize, Deserialize, Debug)]
struct JsonTorrentData {
    id: i64,
    infohash: String,
    name: String,
    size_bytes: i64,
    created_unix: i64,
    seeders: i64,
    leechers: i64,
    completed: i64,
    scraped_date: i64,
}

impl JsonTorrentData {
    fn to_torrent(&self) -> Torrent {
        // Convert bytes to a human-readable size string
        let size_str = format!("{:.2} GB", (self.size_bytes as f64) / 1_000_000_000.0);

        // Convert Unix timestamp to a human-readable date string
        let datetime =
            DateTime::<Utc>::from_timestamp(self.created_unix, 0).unwrap_or_else(Utc::now);
        let date_str = datetime.format("%Y-%m-%d").to_string();

        let mut magnet = format!("magnet:?xt=urn:btih:{}&dn={}", self.infohash, self.name);

        // adding extra trackers
        magnet.push_str(DefaultTrackers::get_trackers().unwrap().as_str());

        Torrent {
            info_hash: self.infohash.clone().to_lowercase(),
            name: self.name.clone(),
            magnet,
            size: size_str,
            date: date_str,
            seeders: self.seeders.to_string(),
            leechers: self.leechers.to_string(),
            total_downloads: self.completed.to_string(),
        }
    }
}
