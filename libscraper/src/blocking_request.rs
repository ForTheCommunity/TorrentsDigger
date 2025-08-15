use std::error::Error;

use anyhow::Result;
use rand::{rng, seq::IndexedRandom};
use reqwest::blocking::{Client, Response};

use crate::{
    request_url_builder_nyaa,
    sources::nyaa_dot_si::{NyaaCategories, NyaaFilter, scrape_and_parse},
    torrent::Torrent,
};

pub fn search_torrent(
    search_input: SearchInput,
) -> Result<Vec<Torrent>, Box<(dyn std::error::Error + 'static)>> {
    let request_url = request_url_builder_nyaa(
        &search_input.torrent_name,
        &search_input.filter,
        &search_input.category,
        &search_input.page_number,
    );

    // sending request
    let response = send_request(request_url)?;

    // scrape & parse
    scrape_and_parse(response)
}

pub struct SearchInput {
    torrent_name: String,
    page_number: i64,
    filter: NyaaFilter,
    category: NyaaCategories,
}

impl SearchInput {
    pub fn new(
        torrent_name: String,
        filter: NyaaFilter,
        category: NyaaCategories,
        page_number: i64,
    ) -> Self {
        SearchInput {
            torrent_name,
            filter,
            category,
            page_number,
        }
    }
}

fn send_request(url: String) -> Result<Response, Box<dyn Error>> {
    // blocking HTTP client
    let http_client = Client::new();

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

    let response = http_client
        .get(url)
        .header("User-Agent", user_agent)
        .send()?;

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

        let response = send_request(url);
        let body = response.unwrap().text().unwrap();

        // Parse the User-Agent from the JSON response
        let user_agent_key = "\"user-agent\": \"";
        let start_index = body.find(user_agent_key).unwrap() + user_agent_key.len();
        let end_index = body[start_index..].find('\"').unwrap() + start_index;
        let user_agent_from_response = &body[start_index..end_index];

        // Assert that the User-Agent from the response is one of the expected User-Agents
        println!("USER AGENT FROM RESPONSE BODY ->>>> {}", body);
        assert!(
            expected_user_agents.contains(&user_agent_from_response),
            "Unexpected User-Agent: {}",
            user_agent_from_response
        );
    }
}
