use std::collections::HashMap;

use crate::sources::{
    available_sources::AllAvailableSources,
    lime_torrents::{LimeTorrentsCategories, LimeTorrentsSortings},
    nyaa::{NyaaCategories, NyaaFilter, NyaaSortings},
    solid_torrents::{SolidTorrentsCategories, SolidTorrentsSortings},
    sukebei_nyaa::{SukebeiNyaaCategories, SukebeiNyaaFilter},
    torrents_csv::TorrentsCsvCategories,
    uindex::{UindexCategories, UindexSortings},
};

pub mod available_sources;
pub mod lime_torrents;
pub mod nyaa;
pub mod solid_torrents;
pub mod sukebei_nyaa;
pub mod torrents_csv;
pub mod uindex;

#[derive(Debug)]
pub struct QueryOptions {
    pub categories: bool,
    pub sortings: bool,
    pub filters: bool,
    pub pagination: bool,
}

pub fn get_source_details() -> HashMap<String, SourceDetails> {
    let mut sources_details: HashMap<String, SourceDetails> = HashMap::new();

    // Inserting NyaaDotSi
    let nyaa_source_details: SourceDetails = SourceDetails {
        source_query_options: NyaaCategories::get_query_options(),
        source_categories: NyaaCategories::all_categories(),
        source_filters: NyaaFilter::all_nyaa_filters(),
        source_sortings: NyaaSortings::all_nyaa_sortings(),
    };
    sources_details.insert(AllAvailableSources::Nyaa.to_string(), nyaa_source_details);

    // Inserting SukebeiNyaaDotSi
    let sukebei_nyaa_source_details: SourceDetails = SourceDetails {
        source_query_options: SukebeiNyaaCategories::get_query_options(),
        source_categories: SukebeiNyaaCategories::all_categories(),
        source_filters: SukebeiNyaaFilter::all_sukebei_nyaa_filters(),
        source_sortings: NyaaSortings::all_nyaa_sortings(), // same sortings for sukebei
    };
    sources_details.insert(
        AllAvailableSources::SukebeiNyaa.to_string(),
        sukebei_nyaa_source_details,
    );

    // Inserting TorrentsCsvDotCom
    let torrents_csv_source_details: SourceDetails = SourceDetails {
        source_query_options: TorrentsCsvCategories::get_query_options(),
        source_categories: TorrentsCsvCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: vec!["".to_string()],
    };
    sources_details.insert(
        AllAvailableSources::TorrentsCsv.to_string(),
        torrents_csv_source_details,
    );

    let uindex_source_details = SourceDetails {
        source_query_options: UindexCategories::get_query_options(),
        source_categories: UindexCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: UindexSortings::all_uindex_sortings(),
    };
    sources_details.insert(
        AllAvailableSources::Uindex.to_string(),
        uindex_source_details,
    );

    let lime_torrents_source_details = SourceDetails {
        source_query_options: LimeTorrentsCategories::get_query_options(),
        source_categories: LimeTorrentsCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: LimeTorrentsSortings::all_limetorrents_sortings(),
    };
    sources_details.insert(
        AllAvailableSources::LimeTorrents.to_string(),
        lime_torrents_source_details,
    );

    let solid_torrents_source_details = SourceDetails {
        source_query_options: SolidTorrentsCategories::get_query_options(),
        source_categories: SolidTorrentsCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: SolidTorrentsSortings::all_solid_torrents_sortings(),
    };
    sources_details.insert(
        AllAvailableSources::SolidTorrents.to_string(),
        solid_torrents_source_details,
    );
    sources_details
}

#[derive(Debug)]
pub struct SourceDetails {
    pub source_query_options: QueryOptions,
    pub source_categories: Vec<String>,
    pub source_filters: Vec<String>,
    pub source_sortings: Vec<String>,
}
