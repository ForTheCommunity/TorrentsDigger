// This Binary is for testing Libscraper library.

use std::collections::HashMap;

use libscrapper::{
    blocking_request::fetch_torrents,
    sources::{
        available_sources::AllAvailableSources,
        nyaa_dot_si::{NyaaCategories, NyaaFilter},
        torrents_csv_dot_com::TorrentsCsvCategories,
    },
};

fn main() {
    test_nyaa_dot_si();
    test_torrents_csv_dot_com();
}

fn test_torrents_csv_dot_com() {
    // let SearchInput: SearchInput
    let url = TorrentsCsvCategories::request_url_builder_torrents_csv("The Matrix");
    // let response
    let response = fetch_torrents(url, AllAvailableSources::TorrentsCsvDotCom);
    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.len());
            println!("{:#?}", torrents);
        }
        Err(error) => {
            println!("Error Occurred : {:?}", error);
        }
    }
}

fn test_nyaa_dot_si() {
    let url = NyaaCategories::request_url_builder(
        "Idaten Jump",
        &NyaaFilter::NoFilter,
        &NyaaCategories::AllCategories,
        &1,
    );

    let response = fetch_torrents(url, AllAvailableSources::NyaaDotSi);

    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.len());
        }
        Err(error) => {
            println!("Error Occurred : {:?}", error);
        }
    }

    // testing nyaa categories
    let all_nyaa_categories = NyaaCategories::all_categories();
    println!("Raw Vector --->> {:?}", all_nyaa_categories);
    println!("All Available Nyaa Categories : ");

    for (index, a_category) in all_nyaa_categories.iter().enumerate() {
        println!("{}. {}", index + 1, a_category);
    }

    // Hashmap
    let all_nyaa_categories: Vec<NyaaCategories> = NyaaCategories::all_categories();

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
