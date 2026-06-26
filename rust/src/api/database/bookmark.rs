use std::collections::HashSet;

use lib_torrents_digger::database::bookmark::{
    fetch_all_info_hashes, search_bookmark, BookmarkCategory,
};

use crate::api::{internals::InternalBookmarkCategory, preludes::*};

pub fn bookmark_a_torrent(torrent: InternalTorrent, category_id: u8) -> Result<usize, String> {
    match create_a_bookmark(
        lib_torrents_digger::torrent::Torrent {
            info_hash: torrent.info_hash,
            name: torrent.name,
            magnet: torrent.magnet,
            size: torrent.size,
            date: torrent.date,
            seeders: torrent.seeders,
            leechers: torrent.leechers,
            total_downloads: torrent.total_downloads,
            source_url: torrent.source_url,
        },
        category_id,
    ) {
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

pub fn get_bookmarks(
    category_id: u8,
    limit: u32,
    offset: u32,
) -> Result<Vec<InternalTorrent>, String> {
    match fetch_bookmarks(category_id, limit, offset) {
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
                source_url: t.source_url,
            })
            .collect()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_all_info_hashes() -> Result<HashSet<String>, String> {
    match fetch_all_info_hashes() {
        Ok(a) => Ok(a),
        Err(e) => Err(e.to_string()),
    }
}

pub fn get_categories() -> Result<Vec<InternalBookmarkCategory>, String> {
    match BookmarkCategory::get() {
        Ok(external_bookmark_category_vec) => {
            let mut internal_bookmark_category_vec: Vec<InternalBookmarkCategory> = Vec::new();
            for a_bookmark_category in external_bookmark_category_vec {
                internal_bookmark_category_vec.push(InternalBookmarkCategory {
                    id: a_bookmark_category.id,
                    name: a_bookmark_category.name,
                });
            }
            Ok(internal_bookmark_category_vec)
        }
        Err(e) => Err(e.to_string()),
    }
}

pub fn create_bookmark_category(category_name: String) -> Result<(), String> {
    match BookmarkCategory::create(&category_name) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn rename_bookmark_category(
    category_id: u8,
    old_category_name: String,
    new_category_name: String,
) -> Result<(), String> {
    match BookmarkCategory::rename(category_id, old_category_name, new_category_name) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn delete_bookmark_category(category_id: u8) -> Result<(), String> {
    if category_id == 0 {
        return Err("Cannot delete Uncategorized category".to_string());
    }

    match BookmarkCategory::delete(category_id) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn change_bookmark_category(info_hash: String, category_id: u8) -> Result<(), String> {
    match BookmarkCategory::move_category(info_hash, category_id) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn search_bookmarks(text: String) -> Result<Vec<InternalTorrent>, String> {
    match search_bookmark(text) {
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
                source_url: t.source_url,
            })
            .collect()),
        Err(e) => Err(e.to_string()),
    }
}
