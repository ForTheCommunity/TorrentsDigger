use crate::api::{
    internals::{InternalCustomSourceDetails, InternalPagination},
    preludes::*,
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
            filters: a_external_source
                .source_details
                .source_query_options
                .filters,
            sortings: a_external_source
                .source_details
                .source_query_options
                .sortings,
            sorting_orders: a_external_source
                .source_details
                .source_query_options
                .sorting_orders,
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
            source_sorting_orders: a_external_source.source_details.source_sorting_orders,
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
    sorting_order_index: usize,
    page: Option<i64>,
) -> Result<(Vec<InternalTorrent>, InternalPagination), String> {
    match search_torrent(
        torrent_name,
        source_index,
        category_index,
        filter_index,
        sorting_index,
        sorting_order_index,
        page,
    ) {
        Ok((torrents, pagination)) => {
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

            let internal_pagination = InternalPagination {
                previous_page: pagination.previous_page,
                current_page: pagination.current_page,
                next_page: pagination.next_page,
            };

            Ok((internal_torrents, internal_pagination))
        }

        Err(error) => Err(error.to_string()),
    }
}

pub fn get_ip_details() -> Result<String, String> {
    match extract_ip_details() {
        Ok(a) => Ok(a),
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

pub fn get_customs_details() -> Vec<InternalCustomSourceDetails> {
    let o_v = get_custom_source_details();
    let mut n_v: Vec<InternalCustomSourceDetails> = Vec::new();
    for a in o_v {
        let n_c_s_n = a.custom_source_name;
        let n_c_s_d = a.custom_source_listings;
        n_v.push(InternalCustomSourceDetails {
            custom_source_name: n_c_s_n,
            custom_source_listings: n_c_s_d,
        });
    }
    n_v
}

pub fn dig_custom_torrents(
    selected_source_index: usize,
    selected_listing_index: usize,
) -> Result<(Vec<InternalTorrent>, InternalPagination), String> {
    match search_custom(selected_source_index, selected_listing_index) {
        Ok((torrents, pagination)) => {
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

            let internal_pagination = InternalPagination {
                previous_page: pagination.previous_page,
                current_page: pagination.current_page,
                next_page: pagination.next_page,
            };
            Ok((internal_torrents, internal_pagination))
        }
        Err(error) => Err(error.to_string()),
    }
}
