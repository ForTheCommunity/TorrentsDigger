use std::error::Error;

use anyhow::Result;
use rand::{rng, seq::IndexedRandom};
use ureq::{Agent, Body, http::Response};

use crate::{
    database::proxy::Proxy,
    sources::{
        available_sources::AllAvailableSources, nyaa::NyaaCategories,
        sukebei_nyaa::SukebeiNyaaCategories, torrents_csv::TorrentsCsvCategories,
    },
    torrent::Torrent,
};

pub fn fetch_torrents(
    url: String,
    source: AllAvailableSources,
) -> Result<(Vec<Torrent>, Option<i64>), Box<dyn std::error::Error + 'static>> {
    // sending request
    let response = send_request(url)?;

    // scrape & parseNyaaCategories
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

    // Proxy
    match Proxy::fetch_saved_proxy()? {
        Some(proxy_data) => {
            let proxy_type = proxy_data.proxy_type;
            let proxy_server_ip = proxy_data.proxy_server_ip;
            let proxy_server_port = proxy_data.proxy_server_port;
            let proxy_username: Option<String> = proxy_data.proxy_username;
            let proxy_password: Option<String> = proxy_data.proxy_password;

            let proxy_url = match (proxy_username, proxy_password) {
                (Some(username), Some(password)) => format!(
                    "{}://{}:{}@{}:{}",
                    proxy_type, username, password, proxy_server_ip, proxy_server_port
                ),
                (Some(username), None) => format!(
                    "{}://{}:@{}:{}",
                    proxy_type, username, proxy_server_ip, proxy_server_port
                ),
                (None, Some(password)) => format!(
                    "{}://: {}@{}:{}",
                    proxy_type, password, proxy_server_ip, proxy_server_port
                ),
                (None, None) => {
                    format!("{}://{}:{}", proxy_type, proxy_server_ip, proxy_server_port)
                }
            };
            let proxy = ureq::Proxy::new(&proxy_url)?;
            let agent: Agent = Agent::config_builder().proxy(Some(proxy)).build().into();
            let response = agent.get(url).header("User-Agent", user_agent).call()?;
            Ok(response)
        }
        None => {
            let response = ureq::get(url).header("User-Agent", user_agent).call()?;

            Ok(response)
        }
    }
}

pub enum ProxyTypes {
    NoProxy,
    Http,
    Https,
    Socks4,
    Socks5,
}

impl ProxyTypes {}

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
