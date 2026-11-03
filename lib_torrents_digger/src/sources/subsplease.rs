use anyhow::{Result, anyhow};
use core::fmt;
use serde::Deserialize;
use ureq::{Body, http::Response};

use crate::{
    prepare_info_hash,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SubsPleaseCategories {
    AllCategories,
}

impl SubsPleaseCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: false,
            filters: false,
            sortings: false,
            sorting_orders: false,
            pagination: false,
        }
    }

    const ALL_VARIANTS: &'static [SubsPleaseCategories] = &[Self::AllCategories];

    pub fn from_index(index: usize) -> Option<&'static SubsPleaseCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_categories() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|c| c.to_string()).collect()
    }

    pub fn request_url_builder(torrent_name: &str) -> String {
        let clean = torrent_name.trim();
        if clean.is_empty() {
            "https://subsplease.org/api/?f=latest&tz=$".to_string()
        } else {
            format!(
                "https://subsplease.org/api/?f=search&tz=$&s={}",
                urlencoding::encode(clean)
            )
        }
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let json_text = response
            .body_mut()
            .read_to_string()
            .map_err(|e| anyhow!("Error reading response body: {}", e))?;

        Self::parse_json(&json_text)
    }

    pub fn parse_json(json_text: &str) -> Result<(Vec<Torrent>, Pagination)> {
        let root_val: serde_json::Value = match serde_json::from_str(json_text) {
            Ok(v) => v,
            Err(e) => return Err(anyhow!("Failed to parse JSON response: {}", e)),
        };

        // When no results, SubsPlease API returns an empty array `[]`
        if root_val.is_array() {
            return Ok((Vec::new(), Pagination::new()));
        }

        let map = match root_val.as_object() {
            Some(m) => m,
            None => return Ok((Vec::new(), Pagination::new())),
        };

        let mut torrents = Vec::new();

        for (_key, item_val) in map {
            let item: SubsPleaseItem = match serde_json::from_value(item_val.clone()) {
                Ok(it) => it,
                Err(_) => continue,
            };

            let show_name = item.show.clone().unwrap_or_default();
            let episode = item.episode.clone().unwrap_or_default();
            let date = item.release_date.clone().or(item.time.clone()).unwrap_or_default();
            let source_url = item.page.as_ref().map(|p| {
                if p.starts_with("http") {
                    p.clone()
                } else if p.starts_with('/') {
                    format!("https://subsplease.org{}", p)
                } else {
                    format!("https://subsplease.org/shows/{}", p)
                }
            });

            if let Some(downloads) = item.downloads {
                for dl in downloads {
                    let magnet = match dl.magnet {
                        Some(m) if !m.trim().is_empty() => m,
                        _ => continue,
                    };

                    let info_hash = prepare_info_hash(&magnet).unwrap_or_default();

                    // Parse size from xl field or from magnet link
                    let size = dl
                        .xl
                        .and_then(|v| {
                            if let Some(n) = v.as_u64() {
                                Some(Self::format_bytes(n))
                            } else if let Some(s) = v.as_str() {
                                s.parse::<u64>().ok().map(Self::format_bytes)
                            } else {
                                None
                            }
                        })
                        .or_else(|| Self::parse_size_from_magnet(&magnet))
                        .unwrap_or_default();

                    // Extract display name from dn in magnet, or fallback to formatted title
                    let name = if let Some(dn_part) = magnet.split("&dn=").nth(1) {
                        let encoded_name = dn_part.split('&').next().unwrap_or_default();
                        let with_spaces = encoded_name.replace('+', " ");
                        urlencoding::decode(&with_spaces)
                            .map(|s| s.into_owned())
                            .unwrap_or_else(|_| with_spaces)
                    } else {
                        let res_str = dl.res.as_deref().unwrap_or("");
                        if !res_str.is_empty() {
                            format!("[SubsPlease] {} - {} [{}p]", show_name, episode, res_str)
                        } else {
                            format!("[SubsPlease] {} - {}", show_name, episode)
                        }
                    };

                    torrents.push(Torrent {
                        info_hash,
                        name,
                        magnet,
                        size,
                        date: date.clone(),
                        seeders: "0".to_string(),
                        leechers: "0".to_string(),
                        total_downloads: "0".to_string(),
                        source_url: source_url.clone(),
                    });
                }
            }
        }

        Ok((torrents, Pagination::new()))
    }

    fn parse_size_from_magnet(magnet: &str) -> Option<String> {
        let xl_part = magnet.split("&xl=").nth(1)?;
        let num_str: String = xl_part.chars().take_while(|c| c.is_ascii_digit()).collect();
        let bytes = num_str.parse::<u64>().ok()?;
        Some(Self::format_bytes(bytes))
    }

    pub fn format_bytes(bytes: u64) -> String {
        const KB: u64 = 1024;
        const MB: u64 = 1024 * KB;
        const GB: u64 = 1024 * MB;

        if bytes >= GB {
            format!("{:.2} GB", bytes as f64 / GB as f64)
        } else if bytes >= MB {
            format!("{:.2} MB", bytes as f64 / MB as f64)
        } else if bytes >= KB {
            format!("{:.2} KB", bytes as f64 / KB as f64)
        } else {
            format!("{} B", bytes)
        }
    }
}

impl fmt::Display for SubsPleaseCategories {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
        }
    }
}

#[derive(Deserialize, Debug)]
pub struct SubsPleaseItem {
    pub time: Option<String>,
    pub release_date: Option<String>,
    pub show: Option<String>,
    pub episode: Option<String>,
    pub downloads: Option<Vec<SubsPleaseDownload>>,
    pub page: Option<String>,
}

#[derive(Deserialize, Debug)]
pub struct SubsPleaseDownload {
    pub res: Option<String>,
    pub magnet: Option<String>,
    pub torrent: Option<String>,
    pub xl: Option<serde_json::Value>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_subsplease() {
        let url_search = SubsPleaseCategories::request_url_builder("naruto");
        assert_eq!(
            url_search,
            "https://subsplease.org/api/?f=search&tz=$&s=naruto"
        );

        let url_empty = SubsPleaseCategories::request_url_builder("");
        assert_eq!(url_empty, "https://subsplease.org/api/?f=latest&tz=$");
    }

    #[test]
    fn test_parse_json_subsplease_empty() {
        let empty_json = "[]";
        let (torrents, _) = SubsPleaseCategories::parse_json(empty_json).unwrap();
        assert!(torrents.is_empty());
    }

    #[test]
    fn test_parse_json_subsplease_results() {
        let sample_json = r#"{
            "Choujun! Choujou-senpai - 05": {
                "time": "New",
                "release_date": "Tue, 03 Nov 2026 13:34:10 +0000",
                "show": "Choujun! Choujou-senpai",
                "episode": "05",
                "downloads": [
                    {
                        "res": "480",
                        "magnet": "magnet:?xt=urn:btih:C3DNYLENPMFECLADPASF6XFHOLTYF7OE&dn=%5BSubsPlease%5D%20Choujun%21%20Choujou-senpai%20-%2005%20%28480p%29%20%5B816CB752%5D.mkv&xl=380536958&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce",
                        "xl": 380536958
                    },
                    {
                        "res": "1080",
                        "magnet": "magnet:?xt=urn:btih:YSXMGG5HZL5EK2IJTDNJ6NPMDEQZHDZH&dn=%5BSubsPlease%5D%20Choujun%21%20Choujou-senpai%20-%2005%20%281080p%29%20%5B792ACC64%5D.mkv&xl=1436947347&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce",
                        "xl": 1436947347
                    }
                ],
                "page": "choujun-choujou-senpai"
            }
        }"#;

        let (torrents, _) = SubsPleaseCategories::parse_json(sample_json).unwrap();
        assert_eq!(torrents.len(), 2);

        assert_eq!(
            torrents[0].name,
            "[SubsPlease] Choujun! Choujou-senpai - 05 (480p) [816CB752].mkv"
        );
        assert_eq!(torrents[0].info_hash, "c3dnylenpmfecladpasf6xfholtyf7oe");
        assert_eq!(torrents[0].size, "362.91 MB");
        assert_eq!(
            torrents[0].source_url,
            Some("https://subsplease.org/shows/choujun-choujou-senpai".to_string())
        );

        assert_eq!(
            torrents[1].name,
            "[SubsPlease] Choujun! Choujou-senpai - 05 (1080p) [792ACC64].mkv"
        );
        assert_eq!(torrents[1].info_hash, "ysxmgg5hzl5ek2ijtdnj6npmdeqzhdzh");
        assert_eq!(torrents[1].size, "1.34 GB");
    }
}
