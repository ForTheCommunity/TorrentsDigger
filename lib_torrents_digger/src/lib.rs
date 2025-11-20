use anyhow::{Result, anyhow};

use crate::{
    sources::{
        available_sources::AllAvailableSources,
        knaben_database::{KnabenDatabaseCategories, KnabenDatabaseSortings},
        lime_torrents::{LimeTorrentsCategories, LimeTorrentsSortings},
        nyaa::{NyaaCategories, NyaaFilter, NyaaSortings},
        solid_torrents::{SolidTorrentsCategories, SolidTorrentsSortings},
        sukebei_nyaa::SukebeiNyaaCategories,
        torrents_csv::TorrentsCsvCategories,
        uindex::{UindexCategories, UindexSortings},
    },
    sync_request::fetch_torrents,
};

pub mod database;
pub mod sources;
pub mod static_includes;
pub mod sync_request;
pub mod torrent;
pub mod trackers;

pub fn search_torrent(
    torrent_name: String,
    source_index: usize,
    category_index: usize,
    filter_index: usize,
    sorting: String,
    page: Option<i64>,
) -> Result<(Vec<torrent::Torrent>, Option<i64>)> {
    let source = AllAvailableSources::from_index(source_index)
        .ok_or_else(|| anyhow!("Invalid Source Index: {}", source_index))?;

    match source {
        AllAvailableSources::Nyaa => {
            let category = NyaaCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let filter = NyaaFilter::from_index(filter_index)
                .ok_or_else(|| anyhow!("Invalid Filter Index: {}", filter_index))?;

            let url = NyaaCategories::request_url_builder(
                &torrent_name,
                filter,
                &category,
                &NyaaSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::Nyaa)
        }
        AllAvailableSources::SukebeiNyaa => {
            let category = SukebeiNyaaCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let filter = NyaaFilter::from_index(filter_index)
                .ok_or_else(|| anyhow!("Invalid Filter Index: {}", filter_index))?;

            let url = SukebeiNyaaCategories::request_url_builder(
                &torrent_name,
                filter,
                category,
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
            let category = UindexCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;

            let url = UindexCategories::request_url_builder(
                &torrent_name,
                category,
                &UindexSortings::to_sorting(&sorting),
            );
            fetch_torrents(&url, AllAvailableSources::Uindex)
        }
        AllAvailableSources::LimeTorrents => {
            let category = LimeTorrentsCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;

            let url = LimeTorrentsCategories::request_url_builder(
                &torrent_name,
                category,
                &LimeTorrentsSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::LimeTorrents)
        }
        AllAvailableSources::SolidTorrents => {
            let category = SolidTorrentsCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;

            let url = SolidTorrentsCategories::request_url_builder(
                &torrent_name,
                category,
                &SolidTorrentsSortings::to_sorting(&sorting),
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::SolidTorrents)
        }
        AllAvailableSources::KnabenDatabase => {
            let category = KnabenDatabaseCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;

            let url = KnabenDatabaseCategories::request_url_builder(
                &torrent_name,
                category,
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
