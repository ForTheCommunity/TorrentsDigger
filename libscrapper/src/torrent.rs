// torrent data structure
#[derive(Debug)]
pub struct Torrent {
    pub nyaa_id: i64,
    pub name: String,
    pub torrent_file: String,
    pub magnet_link: String,
    pub size: String,
    pub date: i64,
    pub seeders: i64,
    pub leechers: i64,
    pub approved: i64,
}
