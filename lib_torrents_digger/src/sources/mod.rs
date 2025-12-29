use crate::sources::{
    available_sources::AllAvailableSources,
    customs::custom::Customs,
    knaben_database::{
        KnabenDatabaseCategories, KnabenDatabaseSortingOrders, KnabenDatabaseSortings,
    },
    lime_torrents::{LimeTorrentsCategories, LimeTorrentsSortings},
    nyaa::{NyaaCategories, NyaaFilter, NyaaSortingOrders, NyaaSortings},
    pirate_bay::PirateBayCategories,
    solid_torrents::{SolidTorrentsCategories, SolidTorrentsSortings},
    sukebei_nyaa::SukebeiNyaaCategories,
    torrents_csv::TorrentsCsvCategories,
    uindex::{UindexCategories, UindexSortingOrders, UindexSortings},
};

pub mod available_sources;
pub mod customs;
pub mod knaben_database;
pub mod lime_torrents;
pub mod nyaa;
pub mod pirate_bay;
pub mod solid_torrents;
pub mod sukebei_nyaa;
pub mod torrents_csv;
pub mod uindex;

#[derive(Debug)]
pub struct QueryOptions {
    pub categories: bool,
    pub filters: bool,
    pub sortings: bool,
    pub sorting_orders: bool,
    pub pagination: bool,
}

pub fn get_source_details() -> Vec<Source> {
    let mut sources_details: Vec<Source> = Vec::new();

    // Inserting NyaaDotSi
    let nyaa_source_details: SourceDetails = SourceDetails {
        source_query_options: NyaaCategories::get_query_options(),
        source_categories: NyaaCategories::all_categories(),
        source_filters: NyaaFilter::all_nyaa_filters(),
        source_sortings: NyaaSortings::all_nyaa_sortings(),
        source_sorting_orders: NyaaSortingOrders::all_nyaa_sorting_orders(),
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::Nyaa.to_string(),
        source_details: nyaa_source_details,
    });

    // Inserting SukebeiNyaaDotSi
    let sukebei_nyaa_source_details: SourceDetails = SourceDetails {
        source_query_options: SukebeiNyaaCategories::get_query_options(),
        source_categories: SukebeiNyaaCategories::all_categories(),
        source_filters: NyaaFilter::all_nyaa_filters(), // same filters for sukebei
        source_sortings: NyaaSortings::all_nyaa_sortings(), // same sortings for sukebei
        source_sorting_orders: NyaaSortingOrders::all_nyaa_sorting_orders(), // same sorting orders for sukebei
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::SukebeiNyaa.to_string(),
        source_details: sukebei_nyaa_source_details,
    });

    // Inserting TorrentsCsvDotCom
    let torrents_csv_source_details: SourceDetails = SourceDetails {
        source_query_options: TorrentsCsvCategories::get_query_options(),
        source_categories: TorrentsCsvCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: vec!["".to_string()],
        source_sorting_orders: vec!["".to_string()],
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::TorrentsCsv.to_string(),
        source_details: torrents_csv_source_details,
    });

    let uindex_source_details = SourceDetails {
        source_query_options: UindexCategories::get_query_options(),
        source_categories: UindexCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: UindexSortings::all_uindex_sortings(),
        source_sorting_orders: UindexSortingOrders::all_uindex_sorting_orders(),
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::Uindex.to_string(),
        source_details: uindex_source_details,
    });

    let lime_torrents_source_details = SourceDetails {
        source_query_options: LimeTorrentsCategories::get_query_options(),
        source_categories: LimeTorrentsCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: LimeTorrentsSortings::all_limetorrents_sortings(),
        source_sorting_orders: vec!["".to_string()],
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::LimeTorrents.to_string(),
        source_details: lime_torrents_source_details,
    });

    let solid_torrents_source_details = SourceDetails {
        source_query_options: SolidTorrentsCategories::get_query_options(),
        source_categories: SolidTorrentsCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: SolidTorrentsSortings::all_solid_torrents_sortings(),
        source_sorting_orders: vec!["".to_string()],
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::SolidTorrents.to_string(),
        source_details: solid_torrents_source_details,
    });

    let knaben_database_source_details = SourceDetails {
        source_query_options: KnabenDatabaseCategories::get_query_options(),
        source_categories: KnabenDatabaseCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: KnabenDatabaseSortings::all_sortings(),
        source_sorting_orders: KnabenDatabaseSortingOrders::all_knaben_database_sorting_orders(),
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::KnabenDatabase.to_string(),
        source_details: knaben_database_source_details,
    });

    let the_pirate_bay_source_details = SourceDetails {
        source_query_options: PirateBayCategories::get_query_options(),
        source_categories: PirateBayCategories::all_categories(),
        source_filters: vec!["".to_string()],
        source_sortings: vec!["".to_string()],
        source_sorting_orders: vec!["".to_string()],
    };
    sources_details.push(Source {
        source_name: AllAvailableSources::ThePirateBay.to_string(),
        source_details: the_pirate_bay_source_details,
    });

    sources_details
}

pub fn get_customs() -> Vec<String> {
    Customs::all_customs()
}

#[derive(Debug)]
pub struct SourceDetails {
    pub source_query_options: QueryOptions,
    pub source_categories: Vec<String>,
    pub source_filters: Vec<String>,
    pub source_sortings: Vec<String>,
    pub source_sorting_orders: Vec<String>,
}

#[derive(Debug)]
pub struct Source {
    pub source_name: String,
    pub source_details: SourceDetails,
}
