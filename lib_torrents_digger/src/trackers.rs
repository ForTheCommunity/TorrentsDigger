use anyhow::{Ok, Result, anyhow};
use core::fmt;
use std::{
    fs::{self, File},
    io::Read,
    path::Path,
    sync::{LazyLock, Mutex},
};

use crate::{
    database::{
        database_config::{APP_DIR_NAME, APP_ROOT_DIR, TRACKERS_DIR_PATH, TRACKERS_LISTS_DIR},
        default_trackers::get_active_trackers_list,
        settings_kvs::fetch_kv,
    },
    sync_request::send_request,
};

#[derive(Debug)]
pub enum DefaultTrackers {
    AllTrackers,
    Best20Trackers,
    AllUDPTrackers,
    AllHttpTrackers,
    AllHttpsTrackers,
    AllWSTrackers,
    AllI2PTrackers,
    BestTrackersIpOnly,
    AllTrackersIpOnly,
    AllYggdrasilTrackers,
    AllYggdrasilTrackersIpOnly,
}

impl DefaultTrackers {
    const ALL_VARIANTS: &'static [DefaultTrackers] = &[
        Self::AllTrackers,
        Self::Best20Trackers,
        Self::AllUDPTrackers,
        Self::AllHttpTrackers,
        Self::AllHttpsTrackers,
        Self::AllWSTrackers,
        Self::AllI2PTrackers,
        Self::BestTrackersIpOnly,
        Self::AllTrackersIpOnly,
        Self::AllYggdrasilTrackers,
        Self::AllYggdrasilTrackersIpOnly,
    ];

    pub fn from_index(index: usize) -> Option<&'static DefaultTrackers> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn get_default_trackers_list() -> Vec<(usize, String)> {
        vec![
            Self::AllTrackers,
            Self::Best20Trackers,
            Self::AllUDPTrackers,
            Self::AllHttpTrackers,
            Self::AllHttpsTrackers,
            Self::AllWSTrackers,
            Self::AllI2PTrackers,
            Self::BestTrackersIpOnly,
            Self::AllTrackersIpOnly,
            Self::AllYggdrasilTrackers,
            Self::AllYggdrasilTrackersIpOnly,
        ]
        .into_iter()
        .enumerate()
        .map(|(index, value)| (index, value.to_string()))
        .collect()
    }

    pub fn url(&self) -> &'static str {
        match self {
            Self::AllTrackers => "https://ngosang.github.io/trackerslist/trackers_all.txt",
            Self::Best20Trackers => "https://ngosang.github.io/trackerslist/trackers_best.txt",
            Self::AllUDPTrackers => "https://ngosang.github.io/trackerslist/trackers_all_udp.txt",
            Self::AllHttpTrackers => "https://ngosang.github.io/trackerslist/trackers_all_http.txt",
            Self::AllHttpsTrackers => {
                "https://ngosang.github.io/trackerslist/trackers_all_https.txt"
            }
            Self::AllWSTrackers => "https://ngosang.github.io/trackerslist/trackers_all_ws.txt",
            Self::AllI2PTrackers => "https://ngosang.github.io/trackerslist/trackers_all_i2p.txt",
            Self::BestTrackersIpOnly => {
                "https://ngosang.github.io/trackerslist/trackers_best_ip.txt"
            }
            Self::AllTrackersIpOnly => "https://ngosang.github.io/trackerslist/trackers_all_ip.txt",
            Self::AllYggdrasilTrackers => {
                "https://ngosang.github.io/trackerslist/trackers_all_yggdrasil.txt"
            }
            Self::AllYggdrasilTrackersIpOnly => {
                "https://ngosang.github.io/trackerslist/trackers_all_yggdrasil_ip.txt"
            }
        }
    }

    pub fn get_filename(&self) -> String {
        self.to_string().to_lowercase().replace(' ', "_") + ".txt"
    }

    pub fn download_trackers_lists() -> Result<bool> {
        let trackers_dir_path = TRACKERS_DIR_PATH.get().unwrap();

        for a_variant in Self::ALL_VARIANTS.iter() {
            let url = a_variant.url();
            let file_name = a_variant.get_filename();
            let file_path = trackers_dir_path.join(&file_name);

            // if file is already downloaded then skip
            if file_path.exists() {
                continue;
            }

            let mut response = send_request(url)?;
            if !response.status().is_success() {
                return Err(anyhow!(format!(
                    "Request to {} failed with status {}",
                    url,
                    response.status()
                )));
            }
            let response_body_text = response.body_mut().read_to_string()?;
            fs::write(file_path, response_body_text)?;
        }
        Ok(true)
    }

    pub fn get_magnet_link(mut magnet: String) -> anyhow::Result<String> {
        let trackers_string = TRACKERS_STRING
            .lock()
            .map_err(|_| anyhow!("Failed to lock TRACKERS_STRING"))?
            .clone();
        magnet.push_str(&trackers_string);
        Ok(magnet)
    }
}

impl fmt::Display for DefaultTrackers {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllTrackers => write!(f, "All Trackers"),
            Self::Best20Trackers => write!(f, "20 Best Trackers"),
            Self::AllUDPTrackers => write!(f, "All UDP Trackers"),
            Self::AllHttpTrackers => write!(f, "All Http Trackers"),
            Self::AllHttpsTrackers => write!(f, "All Https Trackers"),
            Self::AllWSTrackers => write!(f, "All WS Trackers"),
            Self::AllI2PTrackers => write!(f, "All I2P Trackers"),
            Self::BestTrackersIpOnly => write!(f, "Best IP Only Trackers"),
            Self::AllTrackersIpOnly => write!(f, "All IP Only Trackers"),
            Self::AllYggdrasilTrackers => write!(f, "All Yggdrasil Trackers"),
            Self::AllYggdrasilTrackersIpOnly => write!(f, "All Yggdrasil IP Only Trackers"),
        }
    }
}

static TRACKERS_STRING: LazyLock<Mutex<String>> =
    LazyLock::new(|| Mutex::new(String::from("this data will be overwrited....")));

pub fn load_trackers_string() -> Result<bool> {
    let active_trackers_list_index = get_active_trackers_list()?.parse::<usize>()?;
    let trackers_list_type = DefaultTrackers::from_index(active_trackers_list_index)
        .ok_or_else(|| anyhow!("Invalid tracker index: {}", active_trackers_list_index))?;
    let file_name = trackers_list_type.get_filename();

    // platform specific root dir
    let app_root_dir_path = fetch_kv(APP_ROOT_DIR)?;

    let file_path = Path::new(&app_root_dir_path)
        .join(APP_DIR_NAME)
        .join(TRACKERS_LISTS_DIR)
        .join(file_name);

    if !file_path.exists() {
        DefaultTrackers::download_trackers_lists()?;
    }

    let mut file = File::open(file_path)?;
    let mut trackers_file_content = String::new();
    file.read_to_string(&mut trackers_file_content)?;

    // String to store trackers.
    let mut trackers = String::new();

    for a_tracker in trackers_file_content.lines() {
        // check for empty lines / gap
        if !a_tracker.trim().is_empty() {
            trackers.push_str("&tr=");
            trackers.push_str(a_tracker);
        }
    }

    let mut data = TRACKERS_STRING.lock().unwrap();
    *data = trackers;
    // for appending
    // let a = data.push_str(&trackers);
    Ok(true)
}
