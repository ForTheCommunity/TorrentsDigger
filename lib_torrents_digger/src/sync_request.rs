use anyhow::{Result, anyhow};

use rand::{rng, seq::IndexedRandom};
use serde::Deserialize;
use ureq::{Agent, Body, http::Response};

use crate::{
    database::proxy::Proxy,
    sources::{
        available_sources::AllAvailableSources, knaben_database::KnabenDatabaseCategories,
        lime_torrents::LimeTorrentsCategories, nyaa::NyaaCategories,
        pirate_bay::PirateBayCategories, solid_torrents::SolidTorrentsCategories,
        sukebei_nyaa::SukebeiNyaaCategories, torrents_csv::TorrentsCsvCategories,
        uindex::UindexCategories,
    },
    static_includes::get_current_version,
    torrent::Torrent,
};

pub fn fetch_torrents(
    url: &str,
    source: AllAvailableSources,
) -> Result<(Vec<Torrent>, Option<i64>)> {
    // sending request
    let response = send_request(url)?;

    // scrape & parse
    match source {
        AllAvailableSources::Nyaa => NyaaCategories::scrape_and_parse(response),
        AllAvailableSources::SukebeiNyaa => SukebeiNyaaCategories::scrape_and_parse(response),
        AllAvailableSources::TorrentsCsv => TorrentsCsvCategories::parse_response(response),
        AllAvailableSources::Uindex => UindexCategories::scrape_and_parse(response),
        AllAvailableSources::LimeTorrents => LimeTorrentsCategories::scrape_and_parse(response),
        AllAvailableSources::SolidTorrents => SolidTorrentsCategories::scrape_and_parse(response),
        AllAvailableSources::KnabenDatabase => KnabenDatabaseCategories::scrape_and_parse(response),
        AllAvailableSources::ThePirateBay => PirateBayCategories::scrape_and_parse(response),
    }
}

pub fn send_request(url: &str) -> Result<Response<Body>> {
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

    // Proxy
    match Proxy::fetch_saved_proxy()? {
        Some(proxy_data) => {
            let proxy_url = build_proxy_url(&proxy_data);
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

pub fn build_proxy_url(proxy_data: &Proxy) -> String {
    let proxy_type = &proxy_data.proxy_type;
    let proxy_server_ip = &proxy_data.proxy_server_ip;
    let proxy_server_port = &proxy_data.proxy_server_port;
    let proxy_username: Option<&String> = proxy_data.proxy_username.as_ref();
    let proxy_password: Option<&String> = proxy_data.proxy_password.as_ref();

    match (proxy_username, proxy_password) {
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
    }
}

pub fn extract_ip_details() -> Result<String> {
    let mut response = send_request("https://ifconfig.so")?;
    let response_body = response.body_mut().read_to_string()?;
    Ok(response_body)
}

pub fn check_for_update() -> Result<u8> {
    // https://gitlab.com/api/v4/projects/73090806/repository/tags

    let url: &'static str = "https://gitlab.com/api/v4/projects/73090806/repository/tags";
    let mut response = send_request(url)?;
    let response_body = response.body_mut().read_to_string()?;

    // Deserializing
    let tags: Vec<Tag> = serde_json::from_str(&response_body)?;
    // latest tag/release is the first.......
    match tags.first() {
        Some(latest_tag) => {
            let latest_version = latest_tag
                .name
                .trim_start_matches("v")
                .split("+")
                .next()
                .unwrap_or(&latest_tag.name);

            let current_version_full = get_current_version()?;
            let current_version = current_version_full
                .split("+")
                .next()
                .unwrap_or(&current_version_full);

            if current_version == latest_version {
                Ok(1)
            } else {
                Ok(0)
            }
        }
        None => Err(anyhow!("Latest Release Not Found !!!")),
    }
}

#[derive(Debug, Deserialize)]
struct Tag {
    name: String,
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

        let mut response = send_request(&url).unwrap();
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
