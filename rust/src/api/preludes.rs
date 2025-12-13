pub use lib_torrents_digger::{
    search_torrent,
    sources::{customs::search_custom, get_customs, get_source_details},
    static_includes::get_current_version,
    sync_request::{check_for_update, extract_ip_details},
    trackers::{load_trackers_string, DefaultTrackers},
};

pub use lib_torrents_digger::sources::Source as ExternalSource;
pub use lib_torrents_digger::torrent::Torrent as ExternalTorrent;

pub use crate::api::internals::{
    InternalQueryOptions, InternalSource, InternalSourceDetails, InternalTorrent,
};

pub use flutter_rust_bridge::frb;
pub use lib_torrents_digger::database::bookmark::{
    check_bookmark, create_a_bookmark, delete_a_bookmark, fetch_all_bookmarks,
};

pub use lib_torrents_digger::database::{
    default_trackers::{get_active_trackers_list, set_trackers_list},
    settings_kvs::fetch_all_kv,
};
pub use std::collections::HashMap;

pub use lib_torrents_digger::database::initialize::initialize_database;
pub use lib_torrents_digger::database::proxy::Proxy;

pub use crate::api::internals::InternalProxy;
