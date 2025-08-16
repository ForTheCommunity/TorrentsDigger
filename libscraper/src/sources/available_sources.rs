use core::fmt;
use std::collections::HashMap;

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

pub fn get_all_available_sources_and_their_categories() -> HashMap<String, Vec<String>> {
    let all_nyaa_categories: Vec<NyaaCategories> = NyaaCategories::all_nyaa_categories();

    // creating HashMap to store available sources with their categories
    let mut sources_categories: HashMap<String, Vec<String>> = HashMap::new();

    // Inserting NyaaDotSi
    let nyaa_categories_as_strings_vector: Vec<String> = all_nyaa_categories
        .iter()
        .map(|category| category.to_string())
        .collect();
    sources_categories.insert(
        AllAvailableSources::NyaaDotSi.to_string(),
        nyaa_categories_as_strings_vector,
    );
    sources_categories
}
