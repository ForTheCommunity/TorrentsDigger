use core::fmt;

use anyhow::Result;

use crate::{
    network_io::sync_request::{fetch_torrents, send_request},
    sources::{
        Pagination, available_sources::AllAvailableSources, the_pirate_bay::ThePirateBayCategories,
        uindex::UindexCategories,
    },
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
    AllNew,
    Anime,
    Games,
    Music,
    Books,
}

impl KnabenDatabaseCustomListings {
    const ALL_VARIANTS: &'static [KnabenDatabaseCustomListings] = &[
        Self::TrendingMovies,
        Self::TrendingTVShows,
        Self::AllNew,
        Self::Anime,
        Self::Games,
        Self::Music,
        Self::Books,
    ];

    pub fn from_index(index: usize) -> Option<&'static KnabenDatabaseCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(
        source: &KnabenDatabaseCustomListings,
    ) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::TrendingMovies => {
                let url = "https://rss.knaben.org//3000000";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::TrendingTVShows => {
                let url = "https://rss.knaben.org//2000000";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::AllNew => {
                let url = "https://rss.knaben.org";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::Anime => {
                let url = "https://rss.knaben.org//6000000";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::Games => {
                let url = "https://rss.knaben.org//4000000|7000000";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::Music => {
                let url = "https://rss.knaben.org//1000000";
                fetch_torrents(url, AllAvailableSources::KnabenDatabase)
            }
            Self::Books => {
                let url = "https://rss.knaben.org//9000000";
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
            Self::AllNew => write!(f, "All New Torrents"),
            Self::Anime => write!(f, "Anime"),
            Self::Games => write!(f, "Games / PC"),
            Self::Music => write!(f, "Music / Audio"),
            Self::Books => write!(f, "Books / Ebooks"),
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

pub enum YtsCustomListings {
    TrendingMovies,
    Latest4K,
    MostSeeded4K,
}

impl YtsCustomListings {
    const ALL_VARIANTS: &'static [YtsCustomListings] = &[
        Self::TrendingMovies,
        Self::Latest4K,
        Self::MostSeeded4K,
    ];

    pub fn from_index(index: usize) -> Option<&'static YtsCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(source: &YtsCustomListings) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::TrendingMovies => {
                let url = "https://yts.gg/trending-movies";
                fetch_torrents(url, AllAvailableSources::Yts)
            }
            Self::Latest4K => {
                let url = "https://yts.gg/browse-movies/0/2160p/all/0/latest/0/all";
                fetch_torrents(url, AllAvailableSources::Yts)
            }
            Self::MostSeeded4K => {
                let url = "https://yts.gg/browse-movies/0/2160p/all/0/seeds/0/all";
                fetch_torrents(url, AllAvailableSources::Yts)
            }
        }
    }
}

impl fmt::Display for YtsCustomListings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::TrendingMovies => write!(f, "Trending Movies"),
            Self::Latest4K => write!(f, "Latest 4K"),
            Self::MostSeeded4K => write!(f, "Most Seeded 4K"),
        }
    }
}

pub enum SubsPleaseCustomListings {
    LatestReleases,
}

impl SubsPleaseCustomListings {
    const ALL_VARIANTS: &'static [SubsPleaseCustomListings] = &[Self::LatestReleases];

    pub fn from_index(index: usize) -> Option<&'static SubsPleaseCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(source: &SubsPleaseCustomListings) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::LatestReleases => {
                let url = "https://subsplease.org/api/?f=latest&tz=$";
                fetch_torrents(url, AllAvailableSources::SubsPlease)
            }
        }
    }
}

impl fmt::Display for SubsPleaseCustomListings {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::LatestReleases => write!(f, "Latest Releases"),
        }
    }
}

pub enum TheRarBgCustomListings {
    Trending10All,
    Trending100Movies,
    Trending100TV,
    Trending100Music,
    Trending100Books,
    Trending100XXX,
    Latest100Movies,
    Movies4K,
    TopPopularMovies,
    XXX4K,
}

impl TheRarBgCustomListings {
    const ALL_VARIANTS: &'static [TheRarBgCustomListings] = &[
        Self::Trending10All,
        Self::Trending100Movies,
        Self::Trending100TV,
        Self::Trending100Music,
        Self::Trending100Books,
        Self::Trending100XXX,
        Self::Latest100Movies,
        Self::Movies4K,
        Self::TopPopularMovies,
        Self::XXX4K,
    ];

    pub fn from_index(index: usize) -> Option<&'static TheRarBgCustomListings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_custom_listings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn fetch_torrents(source: &TheRarBgCustomListings) -> Result<(Vec<Torrent>, Pagination)> {
        match source {
            Self::Trending10All => {
                let url = "https://therarbg.com/trending/10/ALL/1D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Trending100Movies => {
                let url = "https://therarbg.com/trending/100/Movies/3D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Trending100TV => {
                let url = "https://therarbg.com/trending/100/TV/3D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Trending100Music => {
                let url = "https://therarbg.com/trending/100/Music/3D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Trending100Books => {
                let url = "https://therarbg.com/trending/100/Books/3D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Trending100XXX => {
                let url = "https://therarbg.com/trending/100/XXX/3D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Latest100Movies => {
                let url = "https://therarbg.com/top/100/Movies/latest/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::Movies4K => {
                let url = "https://therarbg.com/get-posts/keywords:2160p:category:Movies:time:60D/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::TopPopularMovies => {
                let url = "https://therarbg.com/get-posts/category:Movies:order:-se/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
            Self::XXX4K => {
                let url = "https://therarbg.com/top/100/XXX/4K/";
                fetch_torrents(url, AllAvailableSources::TheRarBg)
            }
        }
    }
}

impl fmt::Display for TheRarBgCustomListings {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Trending10All => write!(f, "Trending 10 (All Categories)"),
            Self::Trending100Movies => write!(f, "Trending 100 Movies"),
            Self::Trending100TV => write!(f, "Trending 100 TV"),
            Self::Trending100Music => write!(f, "Trending 100 Music"),
            Self::Trending100Books => write!(f, "Trending 100 Books"),
            Self::Trending100XXX => write!(f, "Trending 100 XXX"),
            Self::Latest100Movies => write!(f, "Latest 100 Movies"),
            Self::Movies4K => write!(f, "4K Movies"),
            Self::TopPopularMovies => write!(f, "Top 100 Popular Movies"),
            Self::XXX4K => write!(f, "4K XXX"),
        }
    }
}
