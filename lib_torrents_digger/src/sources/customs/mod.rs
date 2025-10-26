use crate::sources::customs::custom::Customs;

pub mod custom;

pub fn search_custom(
    source: String,
) -> Result<(Vec<crate::torrent::Torrent>, Option<i64>), anyhow::Error> {
    Customs::fetch_torrents(&Customs::to_customs(&source))
}
