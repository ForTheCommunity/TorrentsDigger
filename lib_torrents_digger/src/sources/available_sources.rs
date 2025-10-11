use core::fmt;

pub enum AllAvailableSources {
    Nyaa,
    SukebeiNyaa,
    TorrentsCsv,
    Uindex,
    LimeTorrents,
    SolidTorrents,
}

impl fmt::Display for AllAvailableSources {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Nyaa => write!(f, "Nyaa"),
            Self::SukebeiNyaa => write!(f, "Nyaa Sukebei"),
            Self::TorrentsCsv => write!(f, "Torrents Csv"),
            Self::Uindex => write!(f, "Uindex"),
            Self::LimeTorrents => write!(f, "Lime Torrents"),
            Self::SolidTorrents => write!(f, "Solid Torrents"),
        }
    }
}

impl AllAvailableSources {
    pub fn to_source(text_category: &str) -> AllAvailableSources {
        match text_category {
            "Nyaa" => AllAvailableSources::Nyaa,
            "Nyaa Sukebei" => AllAvailableSources::SukebeiNyaa,
            "Torrents Csv" => AllAvailableSources::TorrentsCsv,
            "Uindex" => AllAvailableSources::Uindex,
            "Lime Torrents" => AllAvailableSources::LimeTorrents,
            "Solid Torrents" => AllAvailableSources::SolidTorrents,
            _ => AllAvailableSources::TorrentsCsv,
        }
    }
}
