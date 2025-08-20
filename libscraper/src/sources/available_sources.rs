use core::fmt;
use std::collections::HashMap;

use crate::sources::{nyaa_dot_si::NyaaCategories, torrents_csv_dot_com::TorrentsCsvCategories};

pub enum AllAvailableSources {
    NyaaDotSi,
    TorrentsCsvDotCom,
}

impl fmt::Display for AllAvailableSources {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NyaaDotSi => write!(f, "Nyaa"),
            Self::TorrentsCsvDotCom => write!(f, "Torrents Csv"),
        }
    }
}

impl AllAvailableSources {
    // pub fn get_all_available_sources() -> Vec<String> {
    //     let mut all_sources: Vec<String> = Vec::new();
    //     all_sources.push("nyaa_dot_si".to_string());
    //     all_sources.push("torrents_csv_dot_com".to_string());
    //     all_sources
    // }

    pub fn to_source(text_category: &str) -> AllAvailableSources {
        match text_category {
            "Nyaa" => AllAvailableSources::NyaaDotSi,
            "Torrents Csv" => AllAvailableSources::TorrentsCsvDotCom,
            _ => AllAvailableSources::NyaaDotSi,
        }
    }

    pub fn get_all_available_sources_and_their_categories() -> HashMap<String, Vec<String>> {
        // creating HashMap to store available sources with their categories
        let mut sources_categories: HashMap<String, Vec<String>> = HashMap::new();

        // Inserting NyaaDotSi
        let nyaa_dot_si_categories_as_strings_vector: Vec<String> =
            NyaaCategories::all_categories()
                .iter()
                .map(|category| category.to_string())
                .collect();
        sources_categories.insert(
            AllAvailableSources::NyaaDotSi.to_string(),
            nyaa_dot_si_categories_as_strings_vector,
        );

        // Inserting TorrentsCsvDotCom
        let torrents_csv_dot_com_categories_as_strings_vector: Vec<String> =
            TorrentsCsvCategories::all_categories()
                .iter()
                .map(|category| category.to_string())
                .collect();
        sources_categories.insert(
            AllAvailableSources::TorrentsCsvDotCom.to_string(),
            torrents_csv_dot_com_categories_as_strings_vector,
        );

        sources_categories
    }
}
