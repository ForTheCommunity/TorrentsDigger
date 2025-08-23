// torrent data structure
#[derive(Debug)]
pub struct Torrent {
    pub id: i64,
    pub name: String,
    pub torrent_file: String,
    pub magnet_link: String,
    pub size: String,
    pub date: String,
    pub seeders: i64,
    pub leechers: i64,
    pub total_downloads: i64,
}
