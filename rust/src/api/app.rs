use lib_torrents_digger::{search_torrent, sources::get_source_details};
use std::collections::HashMap;

// FRB is unable to translate Torrent Struct from external crate.
// so Mapping Torrent (ExternalTorrent) Struct With InternalTorrent Struct,
use lib_torrents_digger::sources::SourceDetails as ExternalSourceDetails;
use lib_torrents_digger::torrent::Torrent as ExternalTorrent;
pub struct InternalTorrent {
    pub name: String,
    pub magnet_link: String,
    pub size: String,
    pub date: String,
    pub seeders: i64,
    pub leechers: i64,
    pub total_downloads: i64,
}

pub struct InternalQueryOptions {
    pub categories: bool,
    pub sortings: bool,
    pub filters: bool,
}

pub struct InternalSourceDetails {
    pub query_options: InternalQueryOptions,
    pub categories: Vec<String>,
    pub source_filters: Vec<String>,
    pub source_sortings: Vec<String>,
}

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
                    name: t.name,
                    magnet_link: t.magnet_link,
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
