// this build program will create a file named 'current_version.txt'
// which will contain current version of the app..
// this is a temporary solution....

use std::{env, fs, path::Path};

use serde::Deserialize;

fn main() {
    let current_version_file_name = "current_version.txt";
    // project root dir
    let menifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    let current_version_file_path = Path::new(&menifest_dir).join(current_version_file_name);

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
