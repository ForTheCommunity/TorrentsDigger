use lib_torrents_digger::{
    search_torrent,
    sources::{customs::search_custom, get_customs, get_source_details},
    static_includes::get_current_version,
    sync_request::{check_for_update, extract_ip_details},
    trackers::{load_trackers_string, DefaultTrackers},
};

use lib_torrents_digger::sources::Source as ExternalSource;
use lib_torrents_digger::torrent::Torrent as ExternalTorrent;

use crate::api::internals::{
    InternalIpDetails, InternalQueryOptions, InternalSource, InternalSourceDetails, InternalTorrent,
};

pub fn fetch_source_details() -> Vec<InternalSource> {
    let external_sources_vec: Vec<ExternalSource> = get_source_details();
    let mut internal_sources_vec: Vec<InternalSource> = Vec::new();

    for a_external_source in external_sources_vec {
        let internal_source_name: String = a_external_source.source_name;
        let internal_query_options: InternalQueryOptions = InternalQueryOptions {
            categories: a_external_source
                .source_details
                .source_query_options
                .categories,
            sortings: a_external_source
                .source_details
                .source_query_options
                .sortings,
            filters: a_external_source
                .source_details
                .source_query_options
                .filters,
            pagination: a_external_source
                .source_details
                .source_query_options
                .pagination,
        };
        let internal_source_details: InternalSourceDetails = InternalSourceDetails {
            query_options: internal_query_options,
            categories: a_external_source.source_details.source_categories,
            source_filters: a_external_source.source_details.source_filters,
            source_sortings: a_external_source.source_details.source_sortings,
        };
        let internal_source: InternalSource = InternalSource {
            source_name: internal_source_name,
            source_details: internal_source_details,
        };
        internal_sources_vec.push(internal_source);
    }
    internal_sources_vec
}

pub fn dig_torrent(
    torrent_name: String,
    source_index: usize,
    category_index: usize,
    filter_index: usize,
    sorting_index: usize,
    page: Option<i64>,
) -> Result<(Vec<InternalTorrent>, Option<i64>), String> {
    match search_torrent(
        torrent_name,
        source_index,
        category_index,
        filter_index,
        sorting_index,
        page,
    ) {
        Ok((torrents, next_page)) => {
            let internal_torrents: Vec<InternalTorrent> = torrents
                .into_iter()
                .map(|t: ExternalTorrent| InternalTorrent {
                    info_hash: t.info_hash,
                    name: t.name,
                    magnet: t.magnet,
                    size: t.size,
                    date: t.date,
                    seeders: t.seeders,
                    leechers: t.leechers,
                    total_downloads: t.total_downloads,
                })
                .collect();
            Ok((internal_torrents, next_page))
        }

        Err(error) => Err(error.to_string()),
    }
}

pub fn get_ip_details() -> Result<InternalIpDetails, String> {
    match extract_ip_details() {
        Ok(a) => Ok(InternalIpDetails {
            ip_addr: a.ip_addr,
            isp: a.isp,
            continent: a.continent,
            country: a.country,
            capital: a.capital,
            city: a.city,
            region: a.region,
            latitude: a.latitude,
            longitude: a.longitude,
            timezone: a.timezone,
            flag_unicode: a.flag_unicode,
            is_vpn: a.is_vpn,
            is_tor: a.is_tor,
        }),
        Err(e) => Err(e.to_string()),
    }
}

pub fn check_new_update() -> Result<u8, String> {
    match check_for_update() {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_app_current_version() -> String {
    match get_current_version() {
        Ok(a) => a,
        Err(e) => e.to_string(),
    }
}

pub fn get_all_default_trackers_list() -> Vec<(usize, String)> {
    DefaultTrackers::get_default_trackers_list()
}

pub fn load_default_trackers_string() -> Result<bool, String> {
    match load_trackers_string() {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_processed_magnet_link(unprocessed_magnet: String) -> Result<String, String> {
    match DefaultTrackers::get_magnet_link(unprocessed_magnet) {
        Ok(p_m_l) => Ok(p_m_l),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_customs_details() -> Vec<String> {
    get_customs()
}

pub fn dig_custom_torrents(index: usize) -> Result<(Vec<InternalTorrent>, Option<i64>), String> {
    match search_custom(index) {
        Ok((torrents, next_page)) => {
            let internal_torrents: Vec<InternalTorrent> = torrents
                .into_iter()
                .map(|t: ExternalTorrent| InternalTorrent {
                    info_hash: t.info_hash,
                    name: t.name,
                    magnet: t.magnet,
                    size: t.size,
                    date: t.date,
                    seeders: t.seeders,
                    leechers: t.leechers,
                    total_downloads: t.total_downloads,
                })
                .collect();
            Ok((internal_torrents, next_page))
        }
        Err(error) => Err(error.to_string()),
    }
}
