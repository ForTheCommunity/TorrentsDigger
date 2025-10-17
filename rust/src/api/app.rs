use lib_torrents_digger::{
    search_torrent,
    sources::get_source_details,
    sync_request::{check_for_update, extract_ip_details},
};
use std::collections::HashMap;

use lib_torrents_digger::sources::SourceDetails as ExternalSourceDetails;
use lib_torrents_digger::torrent::Torrent as ExternalTorrent;

use crate::api::internals::{
    InternalIpDetails, InternalQueryOptions, InternalSourceDetails, InternalTorrent,
};

//  Map the external HashMap to an internal HashMap
pub fn fetch_source_details() -> HashMap<String, InternalSourceDetails> {
    let source_details: HashMap<String, ExternalSourceDetails> = get_source_details();

    let mut internal_details: HashMap<String, InternalSourceDetails> = HashMap::new();
    for (source_name, details) in source_details {
        let internal_query_options = InternalQueryOptions {
            categories: details.source_query_options.categories,
            sortings: details.source_query_options.sortings,
            filters: details.source_query_options.filters,
            pagination: details.source_query_options.pagination,
        };
        let internal_source_details = InternalSourceDetails {
            query_options: internal_query_options,
            categories: details.source_categories,
            source_filters: details.source_filters,
            source_sortings: details.source_sortings,
        };
        internal_details.insert(source_name, internal_source_details);
    }
    internal_details
}

pub fn dig_torrent(
    torrent_name: String,
    source: String,
    category: String,
    filter: String,
    sorting: String,
    page: Option<i64>,
) -> Result<(Vec<InternalTorrent>, Option<i64>), String> {
    match search_torrent(torrent_name, source, category, filter, sorting, page) {
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

        Err(error) => {
            let error_message = format!("{}", error);
            Err(error_message)
        }
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
