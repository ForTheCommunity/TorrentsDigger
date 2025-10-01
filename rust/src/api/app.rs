use lib_torrents_digger::{search_torrent, sources::get_source_details};
use std::collections::HashMap;

use lib_torrents_digger::sources::SourceDetails as ExternalSourceDetails;
use lib_torrents_digger::torrent::Torrent as ExternalTorrent;

use crate::api::internals::{InternalQueryOptions, InternalSourceDetails, InternalTorrent};

//  Map the external HashMap to an internal HashMap
pub fn fetch_source_details() -> HashMap<String, InternalSourceDetails> {
    let source_details: HashMap<String, ExternalSourceDetails> = get_source_details();

    let mut internal_details: HashMap<String, InternalSourceDetails> = HashMap::new();
    for (source_name, details) in source_details {
        let internal_query_options = InternalQueryOptions {
            categories: details.source_query_options.categories,
            sortings: details.source_query_options.sortings,
            filters: details.source_query_options.filters,
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
) -> Result<Vec<InternalTorrent>, String> {
    match search_torrent(torrent_name, source, category, filter, sorting) {
        Ok(torrents) => {
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
            Ok(internal_torrents)
        }

        Err(error) => {
            let error_message = format!("{}", error);
            Err(error_message)
        }
    }
}
