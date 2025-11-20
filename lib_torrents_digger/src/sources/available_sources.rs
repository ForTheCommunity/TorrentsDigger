use core::fmt;

pub enum AllAvailableSources {
    Nyaa,
    SukebeiNyaa,
    TorrentsCsv,
    Uindex,
    LimeTorrents,
    SolidTorrents,
    KnabenDatabase,
}

impl AllAvailableSources {
    const ALL_VARIANTS: &'static [AllAvailableSources] = &[
        Self::Nyaa,
        Self::SukebeiNyaa,
        Self::TorrentsCsv,
        Self::Uindex,
        Self::LimeTorrents,
        Self::SolidTorrents,
        Self::KnabenDatabase,
    ];

    pub fn from_index(index: usize) -> Option<&'static AllAvailableSources> {
        Self::ALL_VARIANTS.get(index)
    }
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
            Self::KnabenDatabase => write!(f, "Knaben Database"),
        }
    }
}
