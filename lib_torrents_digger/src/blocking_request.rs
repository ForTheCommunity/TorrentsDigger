use std::error::Error;

use anyhow::Result;
use rand::{rng, seq::IndexedRandom};
use ureq::{Body, http::Response};

use crate::{
    sources::{
        available_sources::AllAvailableSources, nyaa_dot_si::NyaaCategories,
        sukebei_nyaa_dot_si::SukebeiNyaaCategories, torrents_csv_dot_com::TorrentsCsvCategories,
    },
    torrent::Torrent,
};

pub fn fetch_torrents(
    url: String,
    source: AllAvailableSources,
) -> Result<Vec<Torrent>, Box<dyn std::error::Error + 'static>> {
    // sending request
    let response = send_request(url)?;

    // scrape & parse
    match source {
        AllAvailableSources::NyaaDotSi => NyaaCategories::scrape_and_parse(response),
        AllAvailableSources::SukebeiNyaaDotSi => SukebeiNyaaCategories::scrape_and_parse(response),
        AllAvailableSources::TorrentsCsvDotCom => TorrentsCsvCategories::parse_response(response),
    }
}

fn send_request(url: String) -> Result<Response<Body>, Box<dyn Error>> {
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

    let response = ureq::get(url)
        .header("User-Agent", user_agent)
        .call()
        .unwrap();

    Ok(response)
}

// _______________________________________________________________________________________
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn check_user_agent() {
        let url = "https://httpbin.org/user-agent".to_string();

        let expected_user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15",
            "Mozilla/5.0 (Linux; Android 10; Pixel 3 XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
        ];

        let mut response = send_request(url).unwrap();
        let body = response.body_mut().read_to_string().unwrap();

        // parsing json
        let parsed_json_response: serde_json::Value =
            serde_json::from_str(&body).expect("Failed to parse JSON");

        let user_agent = parsed_json_response["user-agent"]
            .as_str()
            .expect("User agent not found");

        // Check if the user agent matches any in the expected list
        let user_agent_matches = expected_user_agents
            .iter()
            .any(|&expected| expected == user_agent);

        // Use assert_eq! to check if the user agent is in the expected list
        assert!(
            user_agent_matches,
            "User agent '{}' does not match any expected user agents.",
            user_agent
        );
    }
}
