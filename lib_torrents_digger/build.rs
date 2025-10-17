// this build program/script downloads all active public trackers from
// https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt
// and save it to a file named all_active_public_trackers.txt
// this program will run on every build,
// these active public trackers will be added in magent link
// or in info_hash to create magnet link

use std::{env, fs, path::Path};

use rand::{rng, seq::IndexedRandom};
use serde::Deserialize;

fn main() {
    // list of addresses of public active bittorrent tracker servers.
    let url = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt";
    let trackers_file_name = "all_active_public_trackers.txt";
    let current_version_file_name = "current_version.txt";
    // project root dir
    let menifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    let tracker_file_path = Path::new(&menifest_dir).join(trackers_file_name);
    let current_version_file_path = Path::new(&menifest_dir).join(current_version_file_name);

    // downloading tracker file

    // List of User-Agent strings
    let user_agents = [
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36,gzip(gfe)",
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1",
    ];

    // Select a random User-Agent
    let mut rng = rng();
    let user_agent = user_agents.choose(&mut rng).unwrap().to_owned();

    match ureq::get(url).header("User-Agent", user_agent).call() {
        Ok(mut response) => match response.body_mut().read_to_string() {
            Ok(response_body) => match fs::write(tracker_file_path, response_body) {
                Ok(_) => {}
                Err(_) => {
                    panic!();
                }
            },
            Err(_) => {
                panic!();
            }
        },
        Err(_) => {
            panic!();
        }
    }

    // extracting current of the app version......
    // Reading the pubspec.yaml file
    match fs::read_to_string("../pubspec.yaml") {
        Ok(yaml_file) => match serde_yml::from_str::<Pubspec>(&yaml_file) {
            Ok(deserialized_pubspec) => {
                if let Some(version) = deserialized_pubspec.version {
                    println!("App version: {}", version);
                    match fs::write(current_version_file_path, version) {
                        Ok(_) => {}
                        Err(e) => {
                            println!("Error : {}", e);
                        }
                    }
                } else {
                    println!("Version field not found.");
                }
            }
            Err(e) => {
                println!("Error : {}", e);
            }
        },
        Err(e) => {
            println!("Error : {}", e);
            panic!();
        }
    }
}
#[derive(Debug, Deserialize)]
struct Pubspec {
    version: Option<String>,
}
