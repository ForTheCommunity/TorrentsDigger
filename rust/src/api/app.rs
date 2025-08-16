use libscrapper::{
    blocking_request::{search_torrent, SearchInput},
    sources::nyaa_dot_si::NyaaCategories,
};

// FRB is unable to translate Torrent Struct from external crate.
// so Mapping Torrent (ExternalTorrent) Struct With InternalTorrent Struct,
// using this technique is a Temporary Solution ,
// This will be / Should be changed in Future.
use libscrapper::torrent::Torrent as ExternalTorrent;
pub struct InternalTorrent {
    pub nyaa_id: i64,
    pub name: String,
    pub torrent_file: String,
    pub magnet_link: String,
    pub size: String,
    pub date: String,
    pub seeders: i64,
    pub leechers: i64,
    pub total_downloads: i64,
}

pub fn dig_torrent(
    torrent_name: String,
    source: String,
    category: String,
) -> Result<Vec<InternalTorrent>, String> {
    println!("[RUST] Searching Torrent : {}", torrent_name);

    let _source = source;
    let category = NyaaCategories::to_category(&category);

    // currently this is hardcoaded for nyaa only. [TODO]
    let search_query = SearchInput::new(
        torrent_name,
        libscrapper::sources::nyaa_dot_si::NyaaFilter::NoFilter,
        category,
        1,
    );

    match search_torrent(search_query) {
        Ok(torrents) => {
            let internal_torrents: Vec<InternalTorrent> = torrents
                .into_iter()
                .map(|t: ExternalTorrent| InternalTorrent {
                    nyaa_id: t.nyaa_id,
                    name: t.name,
                    torrent_file: t.torrent_file,
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
