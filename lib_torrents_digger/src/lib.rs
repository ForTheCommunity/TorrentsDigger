use std::error::Error;

use crate::{
    sources::{
        available_sources::AllAvailableSources,
        nyaa_dot_si::{NyaaCategories, NyaaFilter, NyaaSortings},
        sukebei_nyaa_dot_si::{SukebeiNyaaCategories, SukebeiNyaaFilter},
        torrents_csv_dot_com::TorrentsCsvCategories,
    },
    sync_request::fetch_torrents,
};

pub mod database;
pub mod sources;
pub mod sync_request;
pub mod torrent;
pub mod trackers;

pub fn search_torrent(
    torrent_name: String,
    source: String,
    category: String,
    filter: String,
    sorting: String,
) -> Result<Vec<torrent::Torrent>, Box<dyn Error + 'static>> {
    let source = AllAvailableSources::to_source(&source);
    match source {
        AllAvailableSources::NyaaDotSi => {
            let url = NyaaCategories::request_url_builder(
                &torrent_name,
                &NyaaFilter::to_filter(&filter),
                &NyaaCategories::to_category(&category),
                &NyaaSortings::to_sorting(&sorting),
                &1,
            );
            fetch_torrents(url, AllAvailableSources::NyaaDotSi)
        }
        AllAvailableSources::SukebeiNyaaDotSi => {
            let url = SukebeiNyaaCategories::request_url_builder(
                &torrent_name,
                &SukebeiNyaaFilter::to_filter(&filter),
                &SukebeiNyaaCategories::to_category(&category),
                &NyaaSortings::to_sorting(&sorting),
                &1,
            );
            fetch_torrents(url, AllAvailableSources::SukebeiNyaaDotSi)
        }
        AllAvailableSources::TorrentsCsvDotCom => {
            let url = TorrentsCsvCategories::request_url_builder_torrents_csv(&torrent_name);
            fetch_torrents(url, AllAvailableSources::TorrentsCsvDotCom)
        }
    }
}
