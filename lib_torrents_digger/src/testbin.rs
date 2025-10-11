// This Binary is for testing library.

use std::collections::HashMap;

use lib_torrents_digger::{
    sources::{
        available_sources::AllAvailableSources,
        get_source_details,
        nyaa::{NyaaCategories, NyaaFilter, NyaaSortings},
        torrents_csv::TorrentsCsvCategories,
    },
    sync_request::fetch_torrents,
    trackers::get_trackers,
};

fn main() {
    test_nyaa_dot_si();
    test_torrents_csv_dot_com();
    test_sources_data();
    test_trackers();
}

fn test_sources_data() {
    let source_data = get_source_details();
    println!("________________SOURCE DATA :");
    println!("{:?}", source_data);
}

fn test_torrents_csv_dot_com() {
    // let SearchInput: SearchInput
    let url = TorrentsCsvCategories::request_url_builder_torrents_csv("The Matrix", &None);
    // let response
    let response = fetch_torrents(url, AllAvailableSources::TorrentsCsv);
    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.0.len());
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
        &NyaaSortings::BySeeders,
        &1,
    );

    let response = fetch_torrents(url, AllAvailableSources::Nyaa);

    match response {
        Ok(torrents) => {
            println!("Total Torrents in First Page : {}", torrents.0.len());
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
    let all_nyaa_categories: Vec<String> = NyaaCategories::all_categories();

    // creating HashMap to store available sources with their categories
    let mut sources_categories: HashMap<String, Vec<String>> = HashMap::new();

    // Inserting NyaaDotSi
    let nyaa_categories_as_strings_vector: Vec<String> = all_nyaa_categories
        .iter()
        .map(|category| category.to_string())
        .collect();
    sources_categories.insert(
        AllAvailableSources::Nyaa.to_string(),
        nyaa_categories_as_strings_vector,
    );
    println!("HashMap : {:?}", sources_categories);
}

fn test_trackers() {
    let trackers = get_trackers().unwrap();
    println!("{:?}", trackers);
}
