use core::fmt;

use anyhow::Result;

use crate::{
    sources::{
        Pagination, available_sources::AllAvailableSources, the_pirate_bay::ThePirateBayCategories,
        uindex::UindexCategories,
    },
    sync_request::{fetch_torrents, send_request},
    torrent::Torrent,
};

pub enum NyaaCustomListings {
    Latests,
    Trendings,
}

impl NyaaCustomListings {
    const ALL_VARIANTS: &'static [NyaaCustomListings] = &[Self::Latests, Self::Trendings];

    pub fn from_index(index: usize) -> Option<&'static NyaaCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        [Self::Latests, Self::Trendings]
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(source: &NyaaCustomListings) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::Latests => {
                let url = "https://nyaa.si";
                fetch_torrents(url, AllAvailableSources::Nyaa)
            }
            Self::Trendings => {
                let url = "https://nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::Nyaa)
            }
        }
    }
}

impl fmt::Display for NyaaCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Latests => write!(f, "Latests"),
            Self::Trendings => write!(f, "Trendings"),
        }
    }
}

pub enum SukebeiNyaaCustomListings {
    Latests,
    Trendings,
}

impl SukebeiNyaaCustomListings {
    const ALL_VARIANTS: &'static [SukebeiNyaaCustomListings] = &[Self::Latests, Self::Trendings];

    pub fn from_index(index: usize) -> Option<&'static SukebeiNyaaCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        [Self::Latests, Self::Trendings]
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(
        source: &SukebeiNyaaCustomListings,
    ) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::Latests => {
                let url = "https://sukebei.nyaa.si";
                fetch_torrents(url, AllAvailableSources::SukebeiNyaa)
            }
            Self::Trendings => {
                let url = "https://sukebei.nyaa.si/?s=seeders&o=desc";
                fetch_torrents(url, AllAvailableSources::SukebeiNyaa)
            }
        }
    }
}

impl fmt::Display for SukebeiNyaaCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Latests => write!(f, "Latests"),
            Self::Trendings => write!(f, "Trendings"),
        }
    }
}

pub enum KnabenDatabaseCustomListings {
    TrendingMovies,
    TrendingTVShows,
}

impl KnabenDatabaseCustomListings {
    const ALL_VARIANTS: &'static [KnabenDatabaseCustomListings] =
        &[Self::TrendingMovies, Self::TrendingTVShows];

    pub fn from_index(index: usize) -> Option<&'static KnabenDatabaseCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        [Self::TrendingMovies, Self::TrendingTVShows]
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(
        source: &KnabenDatabaseCustomListings,
    ) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::TrendingMovies => {
                let url = "https://knaben.org/browse/3000000/1/seeders";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::TrendingTVShows => {
                let url = "https://knaben.org/browse/2000000/1/seeders";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
        }
    }
}

impl fmt::Display for KnabenDatabaseCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::TrendingMovies => write!(f, "Trending Movies"),
            Self::TrendingTVShows => write!(f, "Trending TV Shows"),
        }
    }
}

pub enum ThePirateBayCustomListings {
    ThePirateBayLatests,
    ThePirateBayTopMovies,
    ThePirateBayTopUHDMovies,
    ThePirateBayTopTvShows,
    ThePirateBayTopUHDTvShows,
}

impl ThePirateBayCustomListings {
    const ALL_VARIANTS: &'static [ThePirateBayCustomListings] = &[
        Self::ThePirateBayLatests,
        Self::ThePirateBayTopMovies,
        Self::ThePirateBayTopUHDMovies,
        Self::ThePirateBayTopTvShows,
        Self::ThePirateBayTopUHDTvShows,
    ];

    pub fn from_index(index: usize) -> Option<&'static ThePirateBayCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        [
            Self::ThePirateBayLatests,
            Self::ThePirateBayTopMovies,
            Self::ThePirateBayTopUHDMovies,
            Self::ThePirateBayTopTvShows,
            Self::ThePirateBayTopUHDTvShows,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn fetch_torrents(
        source: &ThePirateBayCustomListings,
    ) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::ThePirateBayLatests => {
                let active_domain = ThePirateBayCategories::get_active_domain()?;
                let url = active_domain + "/recent";
                fetch_torrents(&url, AllAvailableSources::ThePirateBay)
            }
            Self::ThePirateBayTopMovies => {
                let active_domain = ThePirateBayCategories::get_active_domain()?;
                let url = active_domain + "/top/201";
                fetch_torrents(&url, AllAvailableSources::ThePirateBay)
            }
            Self::ThePirateBayTopUHDMovies => {
                let active_domain = ThePirateBayCategories::get_active_domain()?;
                let url = active_domain + "/top/211";
                fetch_torrents(&url, AllAvailableSources::ThePirateBay)
            }
            Self::ThePirateBayTopTvShows => {
                let active_domain = ThePirateBayCategories::get_active_domain()?;
                let url = active_domain + "/top/205";
                fetch_torrents(&url, AllAvailableSources::ThePirateBay)
            }
            Self::ThePirateBayTopUHDTvShows => {
                let active_domain = ThePirateBayCategories::get_active_domain()?;
                let url = active_domain + "/top/212";
                fetch_torrents(&url, AllAvailableSources::ThePirateBay)
            }
        }
    }
}

impl fmt::Display for ThePirateBayCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::ThePirateBayLatests => write!(f, "Latests"),
            Self::ThePirateBayTopMovies => write!(f, "Top Movies"),
            Self::ThePirateBayTopUHDMovies => write!(f, "Top UHD Movies"),
            Self::ThePirateBayTopTvShows => write!(f, "Top Tv Shows"),
            Self::ThePirateBayTopUHDTvShows => write!(f, "Top UHD Tv Shows"),
        }
    }
}

pub enum UindexCustomListings {
    TopAll,
    TopMovies,
    TopTV,
    TopGames,
    TopMusic,
    TopApps,
    TopXXX,
    TopAnime,
    TopOthers,
}

impl UindexCustomListings {
    const ALL_VARIANTS: &'static [UindexCustomListings] = &[
        Self::TopAll,
        Self::TopMovies,
        Self::TopTV,
        Self::TopGames,
        Self::TopMusic,
        Self::TopApps,
        Self::TopXXX,
        Self::TopAnime,
        Self::TopOthers,
    ];

    pub fn from_index(index: usize) -> Option<&'static UindexCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        [
            Self::TopAll,
            Self::TopMovies,
            Self::TopTV,
            Self::TopGames,
            Self::TopMusic,
            Self::TopApps,
            Self::TopXXX,
            Self::TopAnime,
            Self::TopOthers,
        ]
        .iter()
        .map(|category| category.to_string())
        .collect()
    }

    pub fn fetch_torrents(source: &UindexCustomListings) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::TopAll => {
                let url = "https://uindex.org/top.php?t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopMovies => {
                let url = "https://uindex.org/top.php?c=1&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopTV => {
                let url = "https://uindex.org/top.php?c=2&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopGames => {
                let url = "https://uindex.org/top.php?c=3&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopMusic => {
                let url = "https://uindex.org/top.php?c=4&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopApps => {
                let url = "https://uindex.org/top.php?c=5&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopXXX => {
                let url = "https://uindex.org/top.php?c=6&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopAnime => {
                let url = "https://uindex.org/top.php?c=7&t=7d";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }

            Self::TopOthers => {
                let url = "https://uindex.org/top.php?c=8&t=6m";
                let response = send_request(url)?;
                UindexCategories::custom_scrape_and_parse(response)
            }
        }
    }
}

impl fmt::Display for UindexCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::TopAll => write!(f, "All Trending"),
            Self::TopMovies => write!(f, "Trending Movies"),
            Self::TopTV => write!(f, "Trending TV Shows"),
            Self::TopGames => write!(f, "Trending Games"),
            Self::TopMusic => write!(f, "Trending Music"),
            Self::TopApps => write!(f, "Trending Apps"),
            Self::TopXXX => write!(f, "Trending XXX"),
            Self::TopAnime => write!(f, "Trending Anime"),
            Self::TopOthers => write!(f, "Other Trendings"),
        }
    }
}
