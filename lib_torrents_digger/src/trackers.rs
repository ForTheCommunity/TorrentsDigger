use core::fmt;

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
