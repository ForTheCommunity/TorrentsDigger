pub use lib_torrents_digger::{
    network_io::sync_request::{check_for_update, extract_ip_details},
    network_io::trackers::{load_trackers_string, DefaultTrackers},
    search_torrent,
    sources::get_source_details,
    static_includes::get_current_version,
};

pub use lib_torrents_digger::sources::Source as ExternalSource;
pub use lib_torrents_digger::torrent::Torrent as ExternalTorrent;

pub use crate::api::internals::{
    InternalQueryOptions, InternalSource, InternalSourceDetails, InternalTorrent,
};

pub use flutter_rust_bridge::frb;
pub use lib_torrents_digger::database::bookmark::{
    create_a_bookmark, delete_a_bookmark, fetch_bookmarks,
};

pub use lib_torrents_digger::database::{
    default_trackers::{get_active_trackers_list, set_trackers_list},
    settings_kvs::fetch_all_kv,
};
pub use std::collections::HashMap;

pub use lib_torrents_digger::database::initialize::initialize_database;
pub use lib_torrents_digger::database::proxy::Proxy;

pub use crate::api::internals::InternalProxy;

pub use lib_torrents_digger::sources::customs::{
    get_custom_source_details, search_custom, CustomSourceDetails,
};

pub use crate::api::internals::{
    InternalBookmarkCategory, InternalBookmarksStats, InternalCategoryStats, InternalCustomDNS,
    InternalCustomSourceDetails, InternalGlobalStats, InternalPagination,
};
pub use lib_torrents_digger::{
    database::bookmark::{BookmarksStats, CategoryStats, GlobalStats},
    network_io::custom_resolver::CustomDNSResolver,
};
