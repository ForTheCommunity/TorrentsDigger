use core::fmt;

pub enum AllAvailableCustomSources {
    Nyaa,
    SukebeiNyaa,
    Uindex,
    KnabenDatabase,
    ThePirateBay,
    Yts,
    SubsPlease,
    TheRarBg,
}

impl AllAvailableCustomSources {
    const ALL_VARIANTS: &'static [AllAvailableCustomSources] = &[
        Self::Nyaa,
        Self::SukebeiNyaa,
        Self::Uindex,
        Self::KnabenDatabase,
        Self::ThePirateBay,
        Self::Yts,
        Self::SubsPlease,
        Self::TheRarBg,
    ];

    pub fn from_index(index: usize) -> Option<&'static AllAvailableCustomSources> {
        Self::ALL_VARIANTS.get(index)
    }
}

impl fmt::Display for AllAvailableCustomSources {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Nyaa => write!(f, "Nyaa"),
            Self::SukebeiNyaa => write!(f, "Nyaa Sukebei"),
            Self::Uindex => write!(f, "Uindex"),
            Self::KnabenDatabase => write!(f, "Knaben Database"),
            Self::ThePirateBay => write!(f, "The Pirate Bay"),
            Self::Yts => write!(f, "YTS"),
            Self::SubsPlease => write!(f, "SubsPlease"),
            Self::TheRarBg => write!(f, "TheRARBG"),
        }
    }
}
