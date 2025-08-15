// torrent categories
#[derive(Debug)]
pub enum NyaaCategories {
    AllCategories,
    Anime,
    AnimeMusicVideo,
    AnimeEnglishTranslated,
    AnimeNonEnglishTranslated,
    AnimeRaw,
    Audio,
    AudioLossLess,
    AudioLossy,
    Literature,
    LiteratureEnglishTranslated,
    LiteratureNonEnglishTranslated,
    LiteratureRaw,
    LiveAction,
    LiveActionEnglishTranslated,
    LiveActionNonEnglishTranslated,
    LiveActionIdolePromotionalVideo,
    LiveActionRaw,
    Pictures,
    PicturesGraphics,
    PicturesPhotos,
    Software,
    SoftwareApplications,
    SoftwareGames,
}

impl NyaaCategories {
    pub fn to_category(text_category: &str) -> NyaaCategories {
        match text_category {
            "Anime - Anime Music Video" => NyaaCategories::AnimeMusicVideo,
            "Anime - English-translated" => NyaaCategories::AnimeEnglishTranslated,
            "Anime - Non-English-translated" => NyaaCategories::AnimeEnglishTranslated,
            "Anime - Raw" => NyaaCategories::AnimeRaw,
            "Audio - Lossless" => NyaaCategories::AudioLossLess,
            "Audio - Lossy" => NyaaCategories::AudioLossy,
            "Literature - English-translated" => NyaaCategories::LiteratureEnglishTranslated,
            "Literature - Non-English-translated" => NyaaCategories::LiteratureNonEnglishTranslated,
            "Literature - Raw" => NyaaCategories::LiteratureRaw,
            "Live Action - English-translated" => NyaaCategories::LiveActionEnglishTranslated,
            "Live Action - Non-English-translated" => {
                NyaaCategories::LiveActionNonEnglishTranslated
            }
            "Live Action - Idol/Promotional Video" => {
                NyaaCategories::LiveActionIdolePromotionalVideo
            }
            "Live Action - Raw" => NyaaCategories::LiveActionRaw,
            "Pictures - Graphics" => NyaaCategories::PicturesGraphics,
            "Pictures - Photos" => NyaaCategories::PicturesPhotos,
            "Software - Applications" => NyaaCategories::SoftwareApplications,
            "Software - Games" => NyaaCategories::SoftwareGames,
            &_ => NyaaCategories::AllCategories,
        }
    }

    pub fn category_to_value(&self) -> String {
        match *self {
            NyaaCategories::AllCategories => "0_0".to_string(),
            NyaaCategories::Anime => "1_0".to_string(),
            NyaaCategories::AnimeMusicVideo => "1_1".to_string(),
            NyaaCategories::AnimeEnglishTranslated => "1_2".to_string(),
            NyaaCategories::AnimeNonEnglishTranslated => "1_3".to_string(),
            NyaaCategories::AnimeRaw => "1_4".to_string(),
            NyaaCategories::Audio => "2_0".to_string(),
            NyaaCategories::AudioLossLess => "2_1".to_string(),
            NyaaCategories::AudioLossy => "2_1".to_string(),
            NyaaCategories::Literature => "3_0".to_string(),
            NyaaCategories::LiteratureEnglishTranslated => "3_1".to_string(),
            NyaaCategories::LiteratureNonEnglishTranslated => "3_2".to_string(),
            NyaaCategories::LiteratureRaw => "3_3".to_string(),
            NyaaCategories::LiveAction => "4_0".to_string(),
            NyaaCategories::LiveActionEnglishTranslated => "4_1".to_string(),
            NyaaCategories::LiveActionIdolePromotionalVideo => "4_2".to_string(),
            NyaaCategories::LiveActionNonEnglishTranslated => "4_3".to_string(),
            NyaaCategories::LiveActionRaw => "4_4".to_string(),
            NyaaCategories::Pictures => "5_0".to_string(),
            NyaaCategories::PicturesGraphics => "5_1".to_string(),
            NyaaCategories::PicturesPhotos => "5_2".to_string(),
            NyaaCategories::Software => "6_0".to_string(),
            NyaaCategories::SoftwareApplications => "6_1".to_string(),
            NyaaCategories::SoftwareGames => "6_2".to_string(),
        }
    }
}

pub enum NyaaFilter {
    NoFilter,
    NoRemakes,
    TrustedOnly,
}

impl NyaaFilter {
    pub fn filter_to_value(&self) -> i32 {
        match *self {
            NyaaFilter::NoFilter => 0,
            NyaaFilter::TrustedOnly => 1,
            NyaaFilter::NoRemakes => 2,
        }
    }

    pub fn to_filter(filter_str: &str) -> Self {
        match filter_str {
            "NoFilter" => NyaaFilter::NoFilter,
            "TrustedOnly" => NyaaFilter::TrustedOnly,
            "NoRemakes" => NyaaFilter::NoRemakes,
            _ => NyaaFilter::NoFilter,
        }
    }
}

#[derive(Debug)]
pub enum NyaaError {
    PageEnded,
    AlreadyAtStartPage,
    PaginationNotPossible,
}

impl std::error::Error for NyaaError {}

impl std::fmt::Display for NyaaError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NyaaError::AlreadyAtStartPage => {
                write!(f, "Already to Start Page , i.e page=1")
            }
            NyaaError::PageEnded => {
                write!(f, "Page Ended , No Page Available.")
            }
            NyaaError::PaginationNotPossible => {
                write!(f, "Page Doesn't Exists.")
            }
        }
    }
}
