use core::fmt;

use anyhow::Result;

use crate::{
    sources::available_sources::AllAvailableSources, sync_request::fetch_torrents, torrent::Torrent,
};

#[derive(Debug)]
pub enum Customs {
    NyaaLatests,
    NyaaTrendings,
    SukebeiNyaaLatests,
    SukebeiNyaaTrendings,
    KnabenTrendingMovies,
    KnabenTrendingTvShows,
}

impl Customs {
    const ALL_VARIANTS: &'static [Customs] = &[
        Self::NyaaLatests,
        Self::NyaaTrendings,
        Self::SukebeiNyaaLatests,
        Self::SukebeiNyaaTrendings,
        Self::KnabenTrendingMovies,
        Self::KnabenTrendingTvShows,
    ];

    pub fn from_index(index: usize) -> Option<&'static Customs> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_customs() -> Vec<String> {
        [
            Self::NyaaLatests,
            Self::NyaaTrendings,
            Self::SukebeiNyaaLatests,
            Self::SukebeiNyaaTrendings,
            Self::KnabenTrendingMovies,
            Self::KnabenTrendingTvShows,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn fetch_torrents(source: &Customs) -> Result<(Vec<Torrent>, Option<i64>)> {
        match source {
            Self::NyaaLatests => {
                let url = "https://nyaa.si";
                fetch_torrents(url, AllAvailableSources::Nyaa)
            }
            Self::NyaaTrendings => {
                let url = "https://nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::Nyaa)
            }
            Self::SukebeiNyaaLatests => {
                let url = "https://sukebei.nyaa.si";
                fetch_torrents(url, AllAvailableSources::SukebeiNyaa)
            }
            Self::SukebeiNyaaTrendings => {
                let url = "https://sukebei.nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::SukebeiNyaa)
            }
            Self::KnabenTrendingMovies => {
                let url = "https://knaben.org/browse/3000000/1/seeders";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::KnabenTrendingTvShows => {
                let url = "https://knaben.org/browse/2000000/1/seeders";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
        }
    }
}

impl fmt::Display for Customs {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NyaaLatests => write!(f, "Nyaa Latests"),
            Self::NyaaTrendings => write!(f, "Nyaa Trendings"),
            Self::SukebeiNyaaLatests => write!(f, "Sukebei Nyaa Latests"),
            Self::SukebeiNyaaTrendings => write!(f, "Sukebei Nyaa Trendings"),
            Self::KnabenTrendingMovies => write!(f, "Knaben Trending Movies"),
            Self::KnabenTrendingTvShows => write!(f, "Knaben Trending Tv Shows"),
        }
    }
}
