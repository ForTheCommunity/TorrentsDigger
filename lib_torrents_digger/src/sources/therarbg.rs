use anyhow::{Result, anyhow};
use core::fmt;
use regex::Regex;
use scraper::{Html, Selector};
use serde_json::Value;
use ureq::{Body, ResponseExt, http::Response};

use crate::{
    network_io::sync_request::{
        get_app_user_agent, get_client_agent, get_domain_cookie, send_request_with_agent,
    },
    prepare_info_hash,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
};

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum TheRarBgCategories {
    AllCategories,
    Movies,
    Tv,
    Games,
    Music,
    Anime,
    Apps,
    Other,
    Books,
    Xxx,
}

impl TheRarBgCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: false,
            sortings: true,
            sorting_orders: false,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [TheRarBgCategories] = &[
        Self::AllCategories,
        Self::Movies,
        Self::Tv,
        Self::Games,
        Self::Music,
        Self::Anime,
        Self::Apps,
        Self::Other,
        Self::Books,
        Self::Xxx,
    ];

    pub fn from_index(index: usize) -> Option<&'static TheRarBgCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> Option<&'static str> {
        match *self {
            Self::AllCategories => None,
            Self::Movies => Some("Movies"),
            Self::Tv => Some("TV"),
            Self::Games => Some("Games"),
            Self::Music => Some("Music"),
            Self::Anime => Some("Anime"),
            Self::Apps => Some("Apps"),
            Self::Other => Some("Other"),
            Self::Books => Some("Books"),
            Self::Xxx => Some("XXX"),
        }
    }

    pub fn all_categories() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|c| c.to_string()).collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &TheRarBgCategories,
        sorting: &TheRarBgSortings,
        page_number: &i64,
    ) -> String {
        let clean_name = torrent_name.trim().replace(':', " ");
        let page = if *page_number <= 0 { 1 } else { *page_number };
        let base = "https://therarbg.com";

        let mut path = String::from("/get-posts/");
        let mut segments = Vec::new();

        if !clean_name.is_empty() {
            segments.push(format!("keywords:{}", urlencoding::encode(&clean_name)));
        }

        if let Some(cat) = category.category_to_value() {
            segments.push(format!("category:{}", cat));
        }

        if let Some(sort) = sorting.sorting_to_value() {
            segments.push(format!("order:{}", sort));
        }

        if !segments.is_empty() {
            path.push_str(&segments.join(":"));
            path.push('/');
        }

        if page > 1 {
            format!("{}{}{}", base, path, format!("?page={}", page))
        } else {
            format!("{}{}", base, path)
        }
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let current_page = response
            .get_uri()
            .to_string()
            .split("page=")
            .nth(1)
            .and_then(|p| p.split('&').next())
            .and_then(|p| p.parse::<i64>().ok())
            .unwrap_or(1);

        let html = response.body_mut().read_to_string()?;
        let (mut torrents, pagination) = Self::parse_html(&html, current_page)?;
        Self::populate_magnets_and_infohashes(&mut torrents);
        Ok((torrents, pagination))
    }

    pub fn parse_html(html: &str, current_page: i64) -> Result<(Vec<Torrent>, Pagination)> {
        let document = Html::parse_document(html);
        let row_selector = Selector::parse("table.sortableTable tbody tr, table.dataTable tbody tr, table tbody tr")
            .map_err(|e| anyhow!("Failed to parse row selector: {:?}", e))?;
        let link_selector = Selector::parse(r#"a[href*="/post-detail/"]"#)
            .map_err(|e| anyhow!("Failed to parse link selector: {:?}", e))?;
        let td_selector = Selector::parse("td")
            .map_err(|e| anyhow!("Failed to parse td selector: {:?}", e))?;

        let mut all_torrents: Vec<Torrent> = Vec::new();

        for tr in document.select(&row_selector) {
            let link_el = match tr.select(&link_selector).next() {
                Some(el) => el,
                None => continue,
            };

            let name = link_el.text().collect::<String>().trim().to_string();
            if name.is_empty() {
                continue;
            }

            let source_url = link_el.attr("href").map(|h| {
                if h.starts_with("http") {
                    h.to_string()
                } else {
                    format!("https://therarbg.com{}", h)
                }
            });

            let tds: Vec<_> = tr.select(&td_selector).collect();

            let mut date = String::new();
            let mut size = String::new();
            let mut seeders = String::new();
            let mut leechers = String::new();

            for td in &tds {
                let id_attr = td.attr("id").unwrap_or("");
                let style_attr = td.attr("style").unwrap_or("");
                let text = td.text().collect::<String>().trim().to_string();

                if id_attr == "added" || text.len() == 10 && text.chars().nth(4) == Some('-') && text.chars().nth(7) == Some('-') {
                    if date.is_empty() {
                        date = text;
                    }
                } else if id_attr == "size" || text.ends_with("GB") || text.ends_with("MB") || text.ends_with("KB") || text.ends_with("TB") || text.ends_with("bytes") {
                    if size.is_empty() {
                        size = text.replace('\u{a0}', " ");
                    }
                } else if id_attr == "seeders" || style_attr.contains("color: green") {
                    seeders = text;
                } else if id_attr == "leechers" || style_attr.contains("color: red") {
                    leechers = text;
                }
            }

            // Fallback by column index if id/style detection didn't capture all fields
            // Typically: C (0), File (1), Category (2), Added (3), Time (4), Size (5), Se (6), Le (7)
            if tds.len() >= 8 {
                if date.is_empty() {
                    date = tds[3].text().collect::<String>().trim().to_string();
                }
                if size.is_empty() {
                    size = tds[5].text().collect::<String>().trim().replace('\u{a0}', " ");
                }
                if seeders.is_empty() {
                    seeders = tds[6].text().collect::<String>().trim().to_string();
                }
                if leechers.is_empty() {
                    leechers = tds[7].text().collect::<String>().trim().to_string();
                }
            }

            all_torrents.push(Torrent {
                info_hash: String::new(),
                name,
                magnet: String::new(),
                size,
                date,
                seeders,
                leechers,
                total_downloads: String::new(),
                source_url,
            });
        }

        if all_torrents.is_empty() {
            return Err(anyhow!("No torrents found with the specified name."));
        }

        let pagination = Pagination {
            previous_page: if current_page > 1 {
                Some((current_page - 1) as i32)
            } else {
                None
            },
            current_page: Some(current_page as i32),
            next_page: Some((current_page + 1) as i32),
        };

        Ok((all_torrents, pagination))
    }

    pub fn parse_detail_page(content: &str) -> (String, String) {
        let trimmed = content.trim();

        // 1. Check if the content is JSON
        if trimmed.starts_with('{') {
            if let Ok(val) = serde_json::from_str::<Value>(trimmed) {
                let mut magnet = String::new();
                let mut info_hash = String::new();

                if let Some(m) = val.get("magnet").and_then(|v| v.as_str()) {
                    magnet = m.to_string();
                } else if let Some(m) = val.get("download").and_then(|v| v.as_str()) {
                    if m.starts_with("magnet:") {
                        magnet = m.to_string();
                    }
                }

                if let Some(h) = val.get("info_hash").and_then(|v| v.as_str()) {
                    info_hash = h.to_string();
                } else if let Some(h) = val.get("hash").and_then(|v| v.as_str()) {
                    info_hash = h.to_string();
                }

                if info_hash.is_empty() && !magnet.is_empty() {
                    if let Ok(hash) = prepare_info_hash(&magnet) {
                        info_hash = hash;
                    }
                }

                if !magnet.is_empty() || !info_hash.is_empty() {
                    return (magnet, info_hash);
                }
            }
        }

        // 2. Parse as HTML
        let document = Html::parse_document(content);
        let magnet_selector = Selector::parse(r#"a[href^="magnet:?"]"#)
            .or_else(|_| Selector::parse(r#"a[href^="magnet:"]"#))
            .ok();

        let mut magnet = String::new();
        let mut info_hash = String::new();

        if let Some(ref sel) = magnet_selector {
            if let Some(a) = document.select(sel).next() {
                if let Some(href) = a.attr("href") {
                    magnet = href.to_string();
                }
            }
        }

        // Fallback regex search for magnet URI in HTML
        if magnet.is_empty() {
            if let Ok(re) = Regex::new(r#"magnet:\?xt=urn:btih:[a-zA-Z0-9]+"#) {
                if let Some(mat) = re.find(content) {
                    magnet = mat.as_str().to_string();
                }
            }
        }

        if let Ok(hash) = prepare_info_hash(&magnet) {
            info_hash = hash;
        }

        (magnet, info_hash)
    }

    pub fn populate_magnets_and_infohashes(torrents: &mut [Torrent]) {
        if torrents.is_empty() {
            return;
        }

        let agent = match get_client_agent() {
            Ok(a) => std::sync::Arc::new(a),
            Err(_) => return,
        };
        let user_agent = std::sync::Arc::new(get_app_user_agent());
        let cookie = std::sync::Arc::new(get_domain_cookie("therarbg.com"));

        let num_workers = 10.min(torrents.len());
        let (job_tx, job_rx) = std::sync::mpsc::channel::<(usize, String)>();
        let (result_tx, result_rx) = std::sync::mpsc::channel::<(usize, String, String)>();
        let job_rx = std::sync::Arc::new(std::sync::Mutex::new(job_rx));

        for (i, t) in torrents.iter().enumerate() {
            if let Some(ref url) = t.source_url {
                let _ = job_tx.send((i, url.clone()));
            }
        }
        drop(job_tx);

        let mut handles = Vec::new();
        for _ in 0..num_workers {
            let rx = std::sync::Arc::clone(&job_rx);
            let r_tx = result_tx.clone();
            let agent = std::sync::Arc::clone(&agent);
            let ua = std::sync::Arc::clone(&user_agent);
            let ck = std::sync::Arc::clone(&cookie);

            let handle = std::thread::spawn(move || loop {
                let job = {
                    let Ok(guard) = rx.lock() else { break };
                    guard.recv().ok()
                };
                let Some((idx, url)) = job else { break };

                if let Ok(mut res) = send_request_with_agent(&agent, &url, &ua, ck.as_deref()) {
                    if let Ok(body) = res.body_mut().read_to_string() {
                        let (magnet, info_hash) = Self::parse_detail_page(&body);
                        let _ = r_tx.send((idx, magnet, info_hash));
                    }
                }
            });
            handles.push(handle);
        }
        drop(result_tx);

        for (idx, magnet, info_hash) in result_rx {
            if !magnet.is_empty() {
                torrents[idx].magnet = magnet;
            }
            if !info_hash.is_empty() {
                torrents[idx].info_hash = info_hash;
            }
        }

        for handle in handles {
            let _ = handle.join();
        }
    }
}

impl fmt::Display for TheRarBgCategories {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Movies => write!(f, "Movies"),
            Self::Tv => write!(f, "TV"),
            Self::Games => write!(f, "Games"),
            Self::Music => write!(f, "Music"),
            Self::Anime => write!(f, "Anime"),
            Self::Apps => write!(f, "Apps"),
            Self::Other => write!(f, "Other"),
            Self::Books => write!(f, "Books"),
            Self::Xxx => write!(f, "XXX"),
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum TheRarBgSortings {
    Default,
    Seeders,
    Leechers,
    Size,
}

impl TheRarBgSortings {
    const ALL_VARIANTS: &'static [TheRarBgSortings] = &[
        Self::Default,
        Self::Seeders,
        Self::Leechers,
        Self::Size,
    ];

    pub fn from_index(index: usize) -> Option<&'static TheRarBgSortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_to_value(&self) -> Option<&'static str> {
        match *self {
            Self::Default => None,
            Self::Seeders => Some("-se"),
            Self::Leechers => Some("-le"),
            Self::Size => Some("-s"),
        }
    }

    pub fn all_sortings() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|s| s.to_string()).collect()
    }
}

impl fmt::Display for TheRarBgSortings {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::Default => write!(f, "Default"),
            Self::Seeders => write!(f, "Seeders"),
            Self::Leechers => write!(f, "Leechers"),
            Self::Size => write!(f, "Size"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_therarbg() {
        let url_search = TheRarBgCategories::request_url_builder(
            "avengers",
            &TheRarBgCategories::Movies,
            &TheRarBgSortings::Seeders,
            &1,
        );
        assert_eq!(
            url_search,
            "https://therarbg.com/get-posts/keywords:avengers:category:Movies:order:-se/"
        );

        let url_page2 = TheRarBgCategories::request_url_builder(
            "batman",
            &TheRarBgCategories::AllCategories,
            &TheRarBgSortings::Default,
            &2,
        );
        assert_eq!(
            url_page2,
            "https://therarbg.com/get-posts/keywords:batman/?page=2"
        );

        let url_empty = TheRarBgCategories::request_url_builder(
            "",
            &TheRarBgCategories::Tv,
            &TheRarBgSortings::Default,
            &1,
        );
        assert_eq!(
            url_empty,
            "https://therarbg.com/get-posts/category:TV/"
        );
    }

    #[test]
    fn test_parse_html_therarbg() {
        let html = r#"
        <table class="sortableTable compact cell-border hover stripe dataTable no-footer">
          <thead>
            <tr>
              <th class="hideCell">C</th>
              <th class="cellName">File</th>
              <th class="hideCell">Category</th>
              <th id="added">Added</th>
              <th class="hideCell">Time</th>
              <th id="size">Size</th>
              <th id="seeders">Se.</th>
              <th id="leechers">Le.</th>
            </tr>
          </thead>
          <tbody>
            <tr class="odd">
              <td class="hideCell"><img src="/static/rarbg/image/categories/cat_new44.gif"></td>
              <td class="cellName">
                <div class="wrapper">
                  <a href="/post-detail/940ac7/a-quiet-place-trilogy-av1-o5-1-1080p-7rip/" style="font-weight: 700">A Quiet Place (Trilogy) AV1 O5.1 1080p 7RIP</a>
                </div>
              </td>
              <td class="hideCell"><a href="/get-posts/category:Movies/">Movies</a></td>
              <td class="hideCell" data-order="1793711612"><div style="display: inline-block">2026-11-03</div></td>
              <td class="hideCell" data-order="1793711612"><div style="display: inline-block">8&nbsp;minutes</div></td>
              <td style="text-align: left;" data-order="1181116006">1.1&nbsp;GB</td>
              <td style="color: green;">34</td>
              <td style="color: red;">50</td>
            </tr>
          </tbody>
        </table>
        "#;

        let (torrents, pagination) = TheRarBgCategories::parse_html(html, 1).unwrap();
        assert_eq!(torrents.len(), 1);
        assert_eq!(torrents[0].name, "A Quiet Place (Trilogy) AV1 O5.1 1080p 7RIP");
        assert_eq!(
            torrents[0].source_url.as_deref(),
            Some("https://therarbg.com/post-detail/940ac7/a-quiet-place-trilogy-av1-o5-1-1080p-7rip/")
        );
        assert_eq!(torrents[0].date, "2026-11-03");
        assert_eq!(torrents[0].size, "1.1 GB");
        assert_eq!(torrents[0].seeders, "34");
        assert_eq!(torrents[0].leechers, "50");
        assert_eq!(pagination.current_page, Some(1));
        assert_eq!(pagination.next_page, Some(2));
    }

    #[test]
    fn test_parse_detail_page_therarbg() {
        let html = r#"
        <div class="download-container">
            <a href="magnet:?xt=urn:btih:3540FDF6869485BF1B0E2A1C3C012DCE9AE3C206&dn=Test+Movie&tr=udp://tracker.therarbg.com:6969/announce" class="btn btn-primary">Download Magnet</a>
        </div>
        "#;

        let (magnet, info_hash) = TheRarBgCategories::parse_detail_page(html);
        assert_eq!(
            magnet,
            "magnet:?xt=urn:btih:3540FDF6869485BF1B0E2A1C3C012DCE9AE3C206&dn=Test+Movie&tr=udp://tracker.therarbg.com:6969/announce"
        );
        assert_eq!(
            info_hash,
            "3540fdf6869485bf1b0e2a1c3c012dce9ae3c206"
        );

        let json = r#"{"magnet":"magnet:?xt=urn:btih:4540FDF6869485BF1B0E2A1C3C012DCE9AE3C207&dn=Json+Movie","info_hash":"4540fdf6869485bf1b0e2a1c3c012dce9ae3c207"}"#;
        let (magnet_json, info_hash_json) = TheRarBgCategories::parse_detail_page(json);
        assert_eq!(
            magnet_json,
            "magnet:?xt=urn:btih:4540FDF6869485BF1B0E2A1C3C012DCE9AE3C207&dn=Json+Movie"
        );
        assert_eq!(
            info_hash_json,
            "4540fdf6869485bf1b0e2a1c3c012dce9ae3c207"
        );
    }
}
