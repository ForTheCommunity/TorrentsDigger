use std::error::Error;

use crate::{
    blocking_request::fetch_torrents,
    sources::{
        available_sources::AllAvailableSources,
        nyaa_dot_si::{NyaaCategories, NyaaFilter},
        sukebei_nyaa_dot_si::{SukebeiNyaaCategories, SukebeiNyaaFilter},
        torrents_csv_dot_com::TorrentsCsvCategories,
    },
};

pub mod blocking_request;
pub mod sources;
pub mod torrent;

pub fn search_torrent(
    torrent_name: String,
    source: String,
    category: String,
) -> Result<Vec<torrent::Torrent>, Box<dyn Error + 'static>> {
    let source = AllAvailableSources::to_source(&source);
    match source {
        AllAvailableSources::NyaaDotSi => {
            let url = NyaaCategories::request_url_builder(
                &torrent_name,
                &NyaaFilter::NoFilter,
                &NyaaCategories::to_category(&category),
                &1,
            );
            fetch_torrents(url, AllAvailableSources::NyaaDotSi)
        }
        AllAvailableSources::SukebeiNyaaDotSi => {
            let url = SukebeiNyaaCategories::request_url_builder(
                &torrent_name,
                &SukebeiNyaaFilter::NoFilter,
                &SukebeiNyaaCategories::to_category(&category),
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
