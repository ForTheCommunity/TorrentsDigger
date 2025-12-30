use anyhow::{Result, anyhow};

use crate::{
    sources::{
        available_sources::AllAvailableSources,
        knaben_database::{
            KnabenDatabaseCategories, KnabenDatabaseSortingOrders, KnabenDatabaseSortings,
        },
        lime_torrents::{LimeTorrentsCategories, LimeTorrentsSortings},
        nyaa::{NyaaCategories, NyaaFilter, NyaaSortingOrders, NyaaSortings},
        the_pirate_bay::{ThePirateBayCategories, ThePirateBaySortingOrders, ThePirateBaySortings},
        solid_torrents::{SolidTorrentsCategories, SolidTorrentsSortings},
        sukebei_nyaa::SukebeiNyaaCategories,
        torrents_csv::TorrentsCsvCategories,
        uindex::{UindexCategories, UindexSortingOrders, UindexSortings},
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
    sorting_index: usize,
    sorting_order_index: usize,
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
            let sorting = NyaaSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;
            let sorting_order = NyaaSortingOrders::from_index(sorting_order_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_order_index))?;

            let url = NyaaCategories::request_url_builder(
                &torrent_name,
                filter,
                &category,
                sorting,
                sorting_order,
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::Nyaa)
        }
        AllAvailableSources::SukebeiNyaa => {
            let category = SukebeiNyaaCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let filter = NyaaFilter::from_index(filter_index)
                .ok_or_else(|| anyhow!("Invalid Filter Index: {}", filter_index))?;
            let sorting = NyaaSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;
            let sorting_order = NyaaSortingOrders::from_index(sorting_order_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_order_index))?;

            let url = SukebeiNyaaCategories::request_url_builder(
                &torrent_name,
                filter,
                category,
                sorting,
                sorting_order,
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
            let sorting = UindexSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;
            let sorting_order = UindexSortingOrders::from_index(sorting_order_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_order_index))?;

            let url = UindexCategories::request_url_builder(
                &torrent_name,
                category,
                sorting,
                sorting_order,
            );
            fetch_torrents(&url, AllAvailableSources::Uindex)
        }
        AllAvailableSources::LimeTorrents => {
            let category = LimeTorrentsCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let sorting = LimeTorrentsSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;

            let url = LimeTorrentsCategories::request_url_builder(
                &torrent_name,
                category,
                sorting,
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::LimeTorrents)
        }
        AllAvailableSources::SolidTorrents => {
            let category = SolidTorrentsCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let sorting = SolidTorrentsSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;

            let url = SolidTorrentsCategories::request_url_builder(
                &torrent_name,
                category,
                sorting,
                &page.unwrap_or(0),
            );
            fetch_torrents(&url, AllAvailableSources::SolidTorrents)
        }
        AllAvailableSources::KnabenDatabase => {
            let category = KnabenDatabaseCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;
            let sorting = KnabenDatabaseSortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;
            let sorting_order = KnabenDatabaseSortingOrders::from_index(sorting_order_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_order_index))?;

            let url = KnabenDatabaseCategories::request_url_builder(
                &torrent_name,
                category,
                sorting,
                sorting_order,
                &page.unwrap_or(1),
            );
            fetch_torrents(&url, AllAvailableSources::KnabenDatabase)
        }

        AllAvailableSources::ThePirateBay => {
            let category = ThePirateBayCategories::from_index(category_index)
                .ok_or_else(|| anyhow!("Invalid Category Index: {}", source_index))?;

            let sorting = ThePirateBaySortings::from_index(sorting_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_index))?;
            let sorting_order = ThePirateBaySortingOrders::from_index(sorting_order_index)
                .ok_or_else(|| anyhow!("Invalid Sorting Index: {}", sorting_order_index))?;

            let url = ThePirateBayCategories::request_url_builder(
                &torrent_name,
                category,
                sorting,
                sorting_order,
                &page.unwrap_or(1),
            )
            .map_err(|err| anyhow!("Error building Request URL : {}", err))?;

            fetch_torrents(&url, AllAvailableSources::ThePirateBay)
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
