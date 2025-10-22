use core::fmt;
use std::{error::Error, fs};

use crate::{database::database_config::TRACKERS_DIR_PATH, sync_request::send_request};

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
        }
    }

    pub fn get_filename(&self) -> String {
        self.to_string().to_lowercase().replace(' ', "_") + ".txt"
    }

    pub fn download_trackers_lists() -> Result<bool, Box<dyn Error>> {
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
                return Err(format!(
                    "Request to {} failed with status {}",
                    url,
                    response.status()
                )
                .into());
            }
            let response_body_text = response.body_mut().read_to_string()?;
            fs::write(file_path, response_body_text)?;
        }
        Ok(true)
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
        }
    }
}
