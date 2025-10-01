// torrent data structure
#[derive(Debug)]
pub struct Torrent {
    pub info_hash: String,
    pub name: String,
    pub magnet: String,
    pub size: String,
    pub date: String,
    pub seeders: String,
    pub leechers: String,
    pub total_downloads: String,
}
