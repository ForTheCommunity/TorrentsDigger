use std::collections::HashMap;

use crate::sources::{
    available_sources::AllAvailableSources,
    nyaa::nyaa::{NyaaCategories, NyaaFilter, NyaaSortings},
    nyaa::sukebei_nyaa::{SukebeiNyaaCategories, SukebeiNyaaFilter},
    torrents_csv::torrents_csv_dot_com::TorrentsCsvCategories,
};

pub mod available_sources;
pub mod common;
pub mod nyaa;
pub mod torrents_csv;

pub enum SourcesIndex {
    NyaaDotSi = 1,
    SukebeiDotNyaaDotSi = 2,
    TorrentsCsvDotCom = 3,
}

#[derive(Debug)]
pub struct QueryOptions {
    pub categories: bool,
    pub sortings: bool,
    pub filters: bool,
}

pub struct Sortings {
    pub by_size: bool,
    pub by_date: bool,
    pub by_seeders: bool,
    pub by_leechers: bool,
    pub by_total_downloads: bool,
}

pub struct QueryStruct {
    pub source_name: SourcesIndex,
    pub query_options: QueryOptions,
    pub categories: Vec<String>,
    pub filters: Vec<String>,
    pub sortings: Sortings,
}

pub fn get_source_details() -> HashMap<String, SourceDetails> {
    let mut sources_details: HashMap<String, SourceDetails> = HashMap::new();

    // Inserting NyaaDotSi
    let nyaa_dot_si_categories_as_strings_vector: Vec<String> = NyaaCategories::all_categories();
    let nyaa_filters = NyaaFilter::all_nyaa_filters();
    let nyaa_sortings = NyaaSortings::all_nyaa_sortings();
    let nyaa_dot_si_source_details: SourceDetails = SourceDetails {
        source_query_options: NyaaCategories::get_query_options(),
        source_categories: nyaa_dot_si_categories_as_strings_vector,
        source_filters: nyaa_filters,
        source_sortings: nyaa_sortings.clone(),
    };
    sources_details.insert(
        AllAvailableSources::NyaaDotSi.to_string(),
        nyaa_dot_si_source_details,
    );

    // Inserting SukebeiNyaaDotSi
    let sukebei_nyaa_dot_si_categories_as_strings_vector: Vec<String> =
        SukebeiNyaaCategories::all_categories();
    let sukebei_nyaa_filters = SukebeiNyaaFilter::all_sukebei_nyaa_filters();
    // nyaa sortings is same for sukebei also
    let sukebei_nyaa_dot_si_source_details: SourceDetails = SourceDetails {
        source_query_options: SukebeiNyaaCategories::get_query_options(),
        source_categories: sukebei_nyaa_dot_si_categories_as_strings_vector,
        source_filters: sukebei_nyaa_filters,
        source_sortings: nyaa_sortings,
    };
    sources_details.insert(
        AllAvailableSources::SukebeiNyaaDotSi.to_string(),
        sukebei_nyaa_dot_si_source_details,
    );

    // Inserting TorrentsCsvDotCom
    let torrents_csv_dot_com_categories_as_strings_vector: Vec<String> =
        TorrentsCsvCategories::all_categories();
    let torrents_csv_filter = vec!["".to_string()];
    let torrents_csv_dot_com_source_details: SourceDetails = SourceDetails {
        source_query_options: TorrentsCsvCategories::get_query_options(),
        source_categories: torrents_csv_dot_com_categories_as_strings_vector,
        source_filters: torrents_csv_filter,
        source_sortings: vec!["".to_string()],
    };
    sources_details.insert(
        AllAvailableSources::TorrentsCsvDotCom.to_string(),
        torrents_csv_dot_com_source_details,
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
