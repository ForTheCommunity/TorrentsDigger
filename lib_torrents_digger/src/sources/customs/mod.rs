use anyhow::anyhow;

use crate::sources::customs::custom::Customs;

pub mod custom;

pub fn search_custom(
    index: usize,
) -> Result<(Vec<crate::torrent::Torrent>, Option<i64>), anyhow::Error> {
    let custom_varient = Customs::from_index(index)
        .ok_or_else(|| anyhow!("Invalid Custom Listing Index: {}", index))?;
    Customs::fetch_torrents(custom_varient)
}
