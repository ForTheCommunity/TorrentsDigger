use std::error::Error;

use crate::{
    sources::{
        available_sources::AllAvailableSources,
        knaben_database::{KnabenDatabaseCategories, KnabenDatabaseSortings},
        lime_torrents::{LimeTorrentsCategories, LimeTorrentsSortings},
        nyaa::{NyaaCategories, NyaaFilter, NyaaSortings},
        solid_torrents::{SolidTorrentsCategories, SolidTorrentsSortings},
        sukebei_nyaa::{SukebeiNyaaCategories, SukebeiNyaaFilter},
        torrents_csv::TorrentsCsvCategories,
        uindex::{UindexCategories, UindexSortings},
    },
    sync_request::fetch_torrents,
};

pub mod database;
pub mod sources;
pub mod sync_request;
pub mod torrent;
pub mod trackers;
pub mod static_includes;

pub fn search_torrent(
    torrent_name: String,
    source: String,
    category: String,
    filter: String,
    sorting: String,
    page: Option<i64>,
) -> Result<(Vec<torrent::Torrent>, Option<i64>), Box<dyn Error + 'static>> {
    let source = AllAvailableSources::to_source(&source);
    match source {
        AllAvailableSources::Nyaa => {
            let url = NyaaCategories::request_url_builder(
                &torrent_name,
                &NyaaFilter::to_filter(&filter),
                &NyaaCategories::to_category(&category),
                &NyaaSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::Nyaa)
        }
        AllAvailableSources::SukebeiNyaa => {
            let url = SukebeiNyaaCategories::request_url_builder(
                &torrent_name,
                &SukebeiNyaaFilter::to_filter(&filter),
                &SukebeiNyaaCategories::to_category(&category),
                &NyaaSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::SukebeiNyaa)
        }
        AllAvailableSources::TorrentsCsv => {
            let url = TorrentsCsvCategories::request_url_builder_torrents_csv(&torrent_name, &page);
            fetch_torrents(&url, AllAvailableSources::TorrentsCsv)
        }
        AllAvailableSources::Uindex => {
            let url = UindexCategories::request_url_builder(
                &torrent_name,
                &UindexCategories::to_category(&category),
                &UindexSortings::to_sorting(&sorting),
            );
            fetch_torrents(&url, AllAvailableSources::Uindex)
        }
        AllAvailableSources::LimeTorrents => {
            let url = LimeTorrentsCategories::request_url_builder(
                &torrent_name,
                &LimeTorrentsCategories::to_category(&category),
                &LimeTorrentsSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::LimeTorrents)
        }
        AllAvailableSources::SolidTorrents => {
            let url = SolidTorrentsCategories::request_url_builder(
                &torrent_name,
                &SolidTorrentsCategories::to_category(&category),
                &SolidTorrentsSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::SolidTorrents)
        }
        AllAvailableSources::KnabenDatabase => {
            let url = KnabenDatabaseCategories::request_url_builder(
                &torrent_name,
                &KnabenDatabaseCategories::to_category(&category),
                &KnabenDatabaseSortings::to_sorting(&sorting),
                &page.unwrap_or(1),
            );
            fetch_torrents(&url, AllAvailableSources::KnabenDatabase)
        }
    }
}

pub fn extract_info_hash_from_magnet(magnet: &str) -> String {
    // removing magnet link prefix to get info hash start
    let info_hash_start = magnet.trim_start_matches("magnet:?xt=urn:btih:");

    // finding index for first '&' separator i.e for torrent display name and for trackers.
    match info_hash_start.find("&") {
        Some(info_hash_length) => info_hash_start[..info_hash_length].to_string(),
        // if magnet link have no display name & trackers
        None => info_hash_start[..info_hash_start.len()].to_string(),
    }
}
