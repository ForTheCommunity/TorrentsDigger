// this is a custom source
// that shows latest torrents from
// multiple sources.

use core::fmt;

use anyhow::Result;

use crate::{
    sources::available_sources::AllAvailableSources, sync_request::fetch_torrents, torrent::Torrent,
};

#[derive(Debug)]
pub enum Customs {
    NyaaLatest,
    SukebeiNyaaLatest,
}

impl Customs {
    pub fn to_customs(text_customs: &str) -> Self {
        match text_customs {
            "Nyaa Latest" => Self::NyaaLatest,
            "Sukebei Nyaa Latest" => Self::SukebeiNyaaLatest,
            &_ => Self::NyaaLatest,
        }
    }

    pub fn all_customs() -> Vec<String> {
        [Self::NyaaLatest, Self::SukebeiNyaaLatest]
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(source: &Customs) -> Result<(Vec<Torrent>, Option<i64>)> {
        match source {
            Self::NyaaLatest => {
                let url = "https://nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::Nyaa)
            }
            Self::SukebeiNyaaLatest => {
                let url = "https://sukebei.nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::SukebeiNyaa)
            }
        }
    }
}

impl fmt::Display for Customs {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NyaaLatest => write!(f, "Nyaa Latest"),
            Self::SukebeiNyaaLatest => write!(f, "Sukebei Nyaa Latest"),
        }
    }
}
