use std::{env, fs, path::Path};

use rand::{rng, seq::IndexedRandom};

fn main() {
    // list of addresses of public active bittorrent tracker servers.
    let url = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt";
    let file_name = "all_active_public_trackers.txt";
    // project root dir
    let menifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    let file_path = Path::new(&menifest_dir).join(file_name);

    // downloading tracker file

    // List of User-Agent strings
    let user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15",
        "Mozilla/5.0 (Linux; Android 10; Pixel 3 XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
    ];

    // Select a random User-Agent
    let mut rng = rng();
    let user_agent = user_agents.choose(&mut rng).unwrap().to_owned();

    match ureq::get(url).header("User-Agent", user_agent).call() {
        Ok(mut response) => match response.body_mut().read_to_string() {
            Ok(response_body) => match fs::write(file_path, response_body) {
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
}
