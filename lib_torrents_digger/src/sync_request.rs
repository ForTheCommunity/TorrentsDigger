use std::net::IpAddr;

use anyhow::{Result, anyhow};

use regex::Regex;
use serde::Deserialize;
use ua_generator::ua::spoof_ua;
use ureq::{Agent, Body, http::Response};

use crate::{
    database::proxy::Proxy,
    sources::{
        Pagination, available_sources::AllAvailableSources,
        knaben_database::KnabenDatabaseCategories, lime_torrents::LimeTorrentsCategories,
        nyaa::NyaaCategories, solid_torrents::SolidTorrentsCategories,
        sukebei_nyaa::SukebeiNyaaCategories, the_pirate_bay::ThePirateBayCategories,
        torrents_csv::TorrentsCsvCategories, uindex::UindexCategories,
    },
    static_includes::get_current_version,
    torrent::Torrent,
};

pub fn fetch_torrents(
    url: &str,
    source: AllAvailableSources,
) -> Result<(Vec<Torrent>, Pagination)> {
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
        AllAvailableSources::ThePirateBay => ThePirateBayCategories::scrape_and_parse(response),
    }
}

pub fn send_request(url: &str) -> Result<Response<Body>> {
    // random User Agent.
    let user_agent = spoof_ua();

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
    // some ip check endpoints :
    // https://api64.ipify.org/
    // https://api.my-ip.io/v1/ip
    // https://whatismyip.akamai.com/
    // https://ipinfo.io/ip
    // https://ifconfig.so
    // https://checkip.amasonaws.com
    // https://checkip.dyndns.org

    let ip_check_endpoints = [
        "https://api64.ipify.org",
        "https://api.my-ip.io/v1/ip",
        "https://whatismyip.akamai.com",
        "https://ipinfo.io/ip",
        "https://ifconfig.so",
        "https://checkip.amasonaws.com",
        "https://checkip.dyndns.org",
    ];

    // Regex for extracting IPV4 / IPV6 address from response body.
    let ip_regex =
        Regex::new(r"(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b|[0-9a-fA-F:]{1,}/[0-9]{1,3})")?;

    // Vec of Tuple of String to store error for specific endpoint.
    let mut error_messages: Vec<(String, String)> = Vec::new();

    for endpoint in ip_check_endpoints {
        match send_request(endpoint) {
            Ok(mut response) => {
                match response.body_mut().read_to_string() {
                    Ok(response_body) => {
                        // Check for IP addresses in the response body
                        if let Some(captures) = ip_regex.captures(&response_body) {
                            if let Some(ip_str) = captures.get(0) {
                                // parsing to IPV4/6 Address
                                if let Ok(parsed_valid_ip_addr) = ip_str.as_str().parse::<IpAddr>()
                                {
                                    return Ok(parsed_valid_ip_addr.to_string());
                                } else {
                                    let msg = "Invalid IP captured from response".to_string();
                                    error_messages.push((endpoint.into(), msg));
                                    continue;
                                }
                            }
                        } else {
                            let msg = "No IP captured from response".to_string();
                            error_messages.push((endpoint.into(), msg));
                        }
                    }
                    Err(e) => {
                        error_messages.push((endpoint.into(), e.to_string()));
                    }
                }
            }
            Err(e) => {
                error_messages.push((endpoint.into(), e.to_string()));
            }
        }
    }

    let error_message_str = error_messages
        .into_iter()
        .map(|(endpoint, error)| format!("{} -> {}", endpoint, error))
        .collect::<Vec<String>>()
        .join(", ");

    Err(anyhow!(error_message_str))
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
