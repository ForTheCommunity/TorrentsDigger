use core::fmt;

pub enum AllAvailableSources {
    NyaaDotSi,
    SukebeiNyaaDotSi,
    TorrentsCsvDotCom,
}

impl fmt::Display for AllAvailableSources {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NyaaDotSi => write!(f, "Nyaa"),
            Self::SukebeiNyaaDotSi => write!(f, "Nyaa Sukebei"),
            Self::TorrentsCsvDotCom => write!(f, "Torrents Csv"),
        }
    }
}

impl AllAvailableSources {
    pub fn to_source(text_category: &str) -> AllAvailableSources {
        match text_category {
            "Nyaa" => AllAvailableSources::NyaaDotSi,
            "Nyaa Sukebei" => AllAvailableSources::SukebeiNyaaDotSi,
            "Torrents Csv" => AllAvailableSources::TorrentsCsvDotCom,
            _ => AllAvailableSources::NyaaDotSi,
        }
    }
}
