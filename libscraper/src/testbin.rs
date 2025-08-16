use std::{collections::HashMap, ops::Index};

use libscrapper::{
    blocking_request::{SearchInput, search_torrent},
    sources::{
        available_sources::AllAvailableSources,
        nyaa_dot_si::{NyaaCategories, NyaaFilter},
    },
};

fn main() {
    // sending request .... http client...
    let search_input: SearchInput = SearchInput::new(
        "Naruto".to_string(),
        NyaaFilter::NoFilter,
        NyaaCategories::Anime,
        1,
    );
    let response = search_torrent(search_input);

    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.len());
        }
        Err(error) => {
            println!("Error Occurred : {:?}", error);
        }
    }

    // testing nyaa categories
    let all_nyaa_categories = NyaaCategories::all_nyaa_categories();
    println!("Raw Vector --->> {:?}", all_nyaa_categories);
    println!("All Available Nyaa Categories : ");

    for (index, a_category) in all_nyaa_categories.iter().enumerate() {
        println!("{}. {}", index + 1, a_category);
    }

    // Hashmap
    let all_available_sources: Vec<String> = AllAvailableSources::get_all_available_sources();
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
    println!("HashMap : {:?}", sources_categories);
}
