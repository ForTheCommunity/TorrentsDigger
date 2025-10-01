use std::{env, fs, path::Path};
use isahc::ReadResponseExt;

fn main() {
    // list of addresses of public active bittorrent tracker servers.
    let url = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt";
    let file_name = "all_active_public_trackers.txt";
    // project root dir
    let menifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    let file_path = Path::new(&menifest_dir).join(file_name);

    // downloading tracker file

    let mut response = isahc::get(url).unwrap();
    let respnse_body = response.text().unwrap();

    // saving trackers to a file.
    fs::write(file_path, respnse_body).unwrap();
}
