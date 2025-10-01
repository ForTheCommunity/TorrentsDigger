use flutter_rust_bridge::frb;
use lib_torrents_digger::database::bookmark_torrent::{
    check_bookmark, create_a_bookmark, delete_a_bookmark, fetch_all_bookmarks,
};

use crate::api::internals::InternalTorrent;

pub fn bookmark_a_torrent(torrent: InternalTorrent) -> Result<usize, String> {
    create_bookmark(torrent)
}

#[frb(ignore)]
fn create_bookmark(torrent: InternalTorrent) -> Result<usize, String> {
    match create_a_bookmark(lib_torrents_digger::torrent::Torrent {
        info_hash: torrent.info_hash,
        name: torrent.name,
        magnet: torrent.magnet,
        size: torrent.size,
        date: torrent.date,
        seeders: torrent.seeders,
        leechers: torrent.leechers,
        total_downloads: torrent.total_downloads,
    }) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn remove_bookmark(info_hash: String) -> Result<bool, String> {
    match delete_a_bookmark(info_hash) {
        Ok(result) => Ok(result),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_all_bookmarks() -> Result<Vec<InternalTorrent>, String> {
    get_bookmarks()
}

#[frb(ignore)]
fn get_bookmarks() -> Result<Vec<InternalTorrent>, String> {
    match fetch_all_bookmarks() {
        Ok(vec_of_torrent) => Ok(vec_of_torrent
            .into_iter()
            .map(|t: lib_torrents_digger::torrent::Torrent| InternalTorrent {
                info_hash: t.info_hash,
                name: t.name,
                magnet: t.magnet,
                size: t.size,
                date: t.date,
                seeders: t.seeders,
                leechers: t.leechers,
                total_downloads: t.total_downloads,
            })
            .collect()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn check_bookmark_existence(info_hash: String) -> Result<bool, String> {
    match check_bookmark(info_hash) {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}
