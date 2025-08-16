use core::fmt;

use crate::sources::nyaa_dot_si::NyaaCategories;

pub enum AllAvailableSources {
    NyaaDotSi,
    LimeTorrentDotCom,
    OneThreeSevenSevenDotCom,
}

impl fmt::Display for AllAvailableSources {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NyaaDotSi => write!(f, "Nyaa"),
            Self::LimeTorrentDotCom => write!(f, "Lime Torrent"),
            Self::OneThreeSevenSevenDotCom => write!(f, "1337x"),
        }
    }
}

impl AllAvailableSources {
    pub fn get_all_available_sources() -> Vec<String> {
        let mut all_sources: Vec<String> = Vec::new();
        all_sources.push("nyaa_dot_si".to_string());
        all_sources.push("source_a".to_string());
        all_sources.push("source_b".to_string());
        all_sources
    }
}
