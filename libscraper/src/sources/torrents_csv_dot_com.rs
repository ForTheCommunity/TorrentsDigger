use core::fmt;
use std::error::Error;

use crate::torrent::Torrent;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use ureq::{Body, http::Response};

pub enum TorrentsCsvCategories {
    AllCategories,
}

impl TorrentsCsvCategories {
    pub fn to_category(text_category: &str) -> TorrentsCsvCategories {
        match text_category {
            "All Categories" => TorrentsCsvCategories::AllCategories,
            _ => TorrentsCsvCategories::AllCategories,
        }
    }

    pub fn all_categories() -> Vec<Self> {
        vec![Self::AllCategories]
    }

    pub fn request_url_builder_torrents_csv(torrent_name: &str) -> String {
        // https://torrents-csv.com/service/search?q=[QUERY]&size=[NUMBER_OF_RESULTS]&after=[AFTER]
        let torrent_name = torrent_name
            .split_whitespace()
            .collect::<Vec<&str>>()
            .join("+");
        let root_url = "https://torrents-csv.com";
        let results_size = 50;
        let after = 0;
        format!(
            "{}/service/search?q={}&size={}&after={}",
            root_url, torrent_name, results_size, after
        )
    }

    pub fn parse_response(mut response: Response<Body>) -> Result<Vec<Torrent>, Box<dyn Error>> {
        let json_response_txt = response.body_mut().read_to_string()?;
        let json_root: JsonRoot = serde_json::from_str(&json_response_txt)?;
        let torrents: Vec<Torrent> = json_root
            .torrents
            .iter()
            .map(|td| td.to_torrent())
            .collect();
        Ok(torrents)
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
    next: i64,
}

#[derive(Serialize, Deserialize, Debug)]
struct JsonTorrentData {
    rowid: i64,
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
        let datetime = DateTime::<Utc>::from_timestamp(self.created_unix as i64, 0)
            .unwrap_or_else(|| Utc::now());
        let date_str = datetime.format("%Y-%m-%d").to_string();

        let magnet_link = format!("magnet:?xt=urn:btih:{}&dn={}", self.infohash, self.name);

        // Calculate total downloads
        let total_downloads = self.completed + self.seeders;

        Torrent {
            id: self.rowid,
            name: self.name.clone(),
            torrent_file: String::from("N/A"),
            magnet_link,
            size: size_str,
            date: date_str,
            seeders: self.seeders,
            leechers: self.leechers,
            total_downloads,
        }
    }
}
