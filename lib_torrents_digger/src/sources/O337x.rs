use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    network_io::sync_request::{
        get_app_user_agent, get_client_agent, get_domain_cookie, send_request_with_agent,
    },
    prepare_info_hash,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
};

#[derive(Debug, PartialEq, Eq)]
pub enum O337xCategories {
    AllCategories,
    Movies,
    Tv,
    Games,
    Music,
    Applications,
    Documentaries,
    Anime,
    Other,
    Xxx,
}

impl O337xCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: false,
            sortings: true,
            sorting_orders: false,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [O337xCategories] = &[
        Self::AllCategories,
        Self::Movies,
        Self::Tv,
        Self::Games,
        Self::Music,
        Self::Applications,
        Self::Documentaries,
        Self::Anime,
        Self::Other,
        Self::Xxx,
    ];

    pub fn from_index(index: usize) -> Option<&'static O337xCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn category_to_value(&self) -> Option<&'static str> {
        match *self {
            Self::AllCategories => None,
            Self::Movies => Some("Movies"),
            Self::Tv => Some("TV"),
            Self::Games => Some("Games"),
            Self::Music => Some("Music"),
            Self::Applications => Some("Apps"),
            Self::Documentaries => Some("Documentaries"),
            Self::Anime => Some("Anime"),
            Self::Other => Some("Other"),
            Self::Xxx => Some("XXX"),
        }
    }

    pub fn all_categories() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|category| category.to_string())
            .collect()
    }

    pub fn request_url_builder(
        torrent_name: &str,
        category: &O337xCategories,
        sorting: &O337xSortings,
        page_number: &i64,
    ) -> String {
        let torrent_name = urlencoding::encode(torrent_name).to_string();
        let page = if *page_number <= 0 { 1 } else { *page_number };
        let root_url = "https://1337x.to";

        let category_val = category.category_to_value();
        let sorting_val = sorting.sorting_to_value();

        match (category_val, sorting_val) {
            (None, None) => format!("{}/search/{}/{}/", root_url, torrent_name, page),
            (Some(cat), None) => {
                format!(
                    "{}/category-search/{}/{}/{}/",
                    root_url, torrent_name, cat, page
                )
            }
            (None, Some(sort)) => {
                format!(
                    "{}/sort-search/{}/{}/desc/{}/",
                    root_url, torrent_name, sort, page
                )
            }
            (Some(cat), Some(sort)) => {
                format!(
                    "{}/sort-category-search/{}/{}/{}/desc/{}/",
                    root_url, torrent_name, cat, sort, page
                )
            }
        }
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let html_response = response.body_mut().read_to_string()?;
        let (mut torrents, pagination) = Self::parse_html(&html_response)?;

        Self::populate_magnets_and_infohashes(&mut torrents);

        Ok((torrents, pagination))
    }

    pub fn parse_html(html_response: &str) -> Result<(Vec<Torrent>, Pagination)> {
        let document = Html::parse_document(html_response);

        let table_selector = Selector::parse("table.table-list")
            .map_err(|e| anyhow!("Error parsing table selector: {}", e))?;
        let table_body_selector = Selector::parse("tbody")
            .map_err(|e| anyhow!("Error parsing table body selector: {}", e))?;
        let table_row_selector = Selector::parse("tr")
            .map_err(|e| anyhow!("Error parsing table row selector: {}", e))?;
        let name_anchor_selector = Selector::parse(r#"td.coll-1 a[href^="/torrent/"]"#)
            .map_err(|e| anyhow!("Error parsing name anchor selector: {}", e))?;
        let seeds_selector = Selector::parse("td.coll-2")
            .map_err(|e| anyhow!("Error parsing seeds selector: {}", e))?;
        let leeches_selector = Selector::parse("td.coll-3")
            .map_err(|e| anyhow!("Error parsing leeches selector: {}", e))?;
        let date_selector = Selector::parse("td.coll-date")
            .map_err(|e| anyhow!("Error parsing date selector: {}", e))?;
        let size_selector = Selector::parse("td.coll-4")
            .map_err(|e| anyhow!("Error parsing size selector: {}", e))?;

        let pagination_active_selector =
            Selector::parse("div.pagination li.active a, div.pagination li.active")
                .map_err(|e| anyhow!("Error parsing pagination active selector: {}", e))?;
        let pagination_links_selector = Selector::parse("div.pagination li a")
            .map_err(|e| anyhow!("Error parsing pagination links selector: {}", e))?;

        let table = document
            .select(&table_selector)
            .next()
            .ok_or_else(|| anyhow!("No torrents found with the specified name."))?;

        let table_body = table
            .select(&table_body_selector)
            .next()
            .ok_or_else(|| anyhow!("No torrents found with the specified name."))?;

        let mut all_torrents: Vec<Torrent> = Vec::new();

        for row in table_body.select(&table_row_selector) {
            let anchor = match row.select(&name_anchor_selector).next() {
                Some(a) => a,
                None => continue,
            };

            let name = anchor.text().collect::<String>().trim().to_string();
            let href = anchor.attr("href").unwrap_or("");
            let source_url = if !href.is_empty() {
                Some(format!("https://1337x.to{}", href))
            } else {
                None
            };

            let info_hash = href
                .strip_prefix("/torrent/")
                .and_then(|s| s.split('/').next())
                .unwrap_or("")
                .to_string();

            let magnet = String::new();

            let seeders = row
                .select(&seeds_selector)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_else(|| "0".to_string());

            let leechers = row
                .select(&leeches_selector)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_else(|| "0".to_string());

            let date = row
                .select(&date_selector)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_else(|| "N/A".to_string());

            let size = if let Some(size_el) = row.select(&size_selector).next() {
                let direct_text = size_el
                    .children()
                    .filter_map(|c| c.value().as_text().map(|t| t.to_string()))
                    .collect::<String>()
                    .trim()
                    .to_string();
                if !direct_text.is_empty() {
                    direct_text
                } else {
                    size_el.text().collect::<String>().trim().to_string()
                }
            } else {
                "N/A".to_string()
            };

            let total_downloads = "N/A".to_string();

            all_torrents.push(Torrent {
                info_hash,
                name,
                magnet,
                size,
                date,
                seeders,
                leechers,
                total_downloads,
                source_url,
            });
        }

        if all_torrents.is_empty() {
            return Err(anyhow!("No torrents found with the specified name."));
        }

        let mut pagination = Pagination {
            previous_page: None,
            current_page: None,
            next_page: None,
        };

        if let Some(active_el) = document.select(&pagination_active_selector).next() {
            let active_text = active_el.text().collect::<String>().trim().to_string();
            if let Ok(curr) = active_text.parse::<i32>() {
                pagination.current_page = Some(curr);

                if curr > 1 {
                    pagination.previous_page = Some(curr - 1);
                }

                let has_next = document.select(&pagination_links_selector).any(|a| {
                    let text = a.text().collect::<String>().trim().to_string();
                    text == ">>" || text == (curr + 1).to_string()
                });

                if has_next {
                    pagination.next_page = Some(curr + 1);
                }
            }
        }

        Ok((all_torrents, pagination))
    }

    pub fn parse_detail_page(html: &str) -> (String, String) {
        let document = Html::parse_document(html);

        let magnet_selector = Selector::parse(r#"a[href^="magnet:?"]"#)
            .or_else(|_| Selector::parse(r#"a[href^="magnet:"]"#))
            .ok();
        let infohash_selector = Selector::parse("div.infohash-box span").ok();

        let mut magnet = String::new();
        let mut info_hash = String::new();

        if let Some(ref sel) = magnet_selector {
            if let Some(a) = document.select(sel).next() {
                if let Some(href) = a.attr("href") {
                    magnet = href.to_string();
                }
            }
        }

        if let Some(ref sel) = infohash_selector {
            if let Some(span) = document.select(sel).next() {
                info_hash = span.text().collect::<String>().trim().to_string();
            }
        }

        if info_hash.is_empty() && !magnet.is_empty() {
            if let Ok(hash) = prepare_info_hash(&magnet) {
                info_hash = hash;
            }
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
        let cookie = std::sync::Arc::new(get_domain_cookie("1337x.to"));

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

            let handle = std::thread::spawn(move || {
                loop {
                    let job = {
                        let Ok(guard) = rx.lock() else { break };
                        guard.recv().ok()
                    };
                    let Some((idx, url)) = job else { break };

                    if let Ok(mut res) = send_request_with_agent(&agent, &url, &ua, ck.as_deref()) {
                        if let Ok(html) = res.body_mut().read_to_string() {
                            let (magnet, info_hash) = Self::parse_detail_page(&html);
                            let _ = r_tx.send((idx, magnet, info_hash));
                        }
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

        for h in handles {
            let _ = h.join();
        }
    }
}

impl fmt::Display for O337xCategories {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All Categories"),
            Self::Movies => write!(f, "Movies"),
            Self::Tv => write!(f, "TV"),
            Self::Games => write!(f, "Games"),
            Self::Music => write!(f, "Music"),
            Self::Applications => write!(f, "Applications"),
            Self::Documentaries => write!(f, "Documentaries"),
            Self::Anime => write!(f, "Anime"),
            Self::Other => write!(f, "Other"),
            Self::Xxx => write!(f, "XXX"),
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum O337xSortings {
    Default,
    ByTime,
    BySize,
    BySeeders,
    ByLeechers,
}

impl O337xSortings {
    const ALL_VARIANTS: &'static [O337xSortings] = &[
        Self::Default,
        Self::ByTime,
        Self::BySize,
        Self::BySeeders,
        Self::ByLeechers,
    ];

    pub fn from_index(index: usize) -> Option<&'static O337xSortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn sorting_to_value(&self) -> Option<&'static str> {
        match *self {
            Self::Default => None,
            Self::ByTime => Some("time"),
            Self::BySize => Some("size"),
            Self::BySeeders => Some("seeders"),
            Self::ByLeechers => Some("leechers"),
        }
    }

    pub fn all_leetx_sortings() -> Vec<String> {
        Self::ALL_VARIANTS
            .iter()
            .map(|sorting| sorting.to_string())
            .collect()
    }
}

impl fmt::Display for O337xSortings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Default => write!(f, "Default"),
            Self::ByTime => write!(f, "By Time"),
            Self::BySize => write!(f, "By Size"),
            Self::BySeeders => write!(f, "By Seeders"),
            Self::ByLeechers => write!(f, "By Leechers"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_leetx() {
        assert_eq!(
            O337xCategories::request_url_builder(
                "naruto",
                &O337xCategories::AllCategories,
                &O337xSortings::Default,
                &1
            ),
            "https://1337x.to/search/naruto/1/"
        );

        assert_eq!(
            O337xCategories::request_url_builder(
                "naruto",
                &O337xCategories::Movies,
                &O337xSortings::Default,
                &1
            ),
            "https://1337x.to/category-search/naruto/Movies/1/"
        );

        assert_eq!(
            O337xCategories::request_url_builder(
                "naruto",
                &O337xCategories::Applications,
                &O337xSortings::Default,
                &2
            ),
            "https://1337x.to/category-search/naruto/Apps/2/"
        );

        assert_eq!(
            O337xCategories::request_url_builder(
                "naruto",
                &O337xCategories::AllCategories,
                &O337xSortings::ByTime,
                &1
            ),
            "https://1337x.to/sort-search/naruto/time/desc/1/"
        );

        assert_eq!(
            O337xCategories::request_url_builder(
                "naruto",
                &O337xCategories::Movies,
                &O337xSortings::BySeeders,
                &1
            ),
            "https://1337x.to/sort-category-search/naruto/Movies/seeders/desc/1/"
        );
    }

    #[test]
    fn test_parse_html_leetx() {
        let sample_html = r#"
        <div class="box-info-detail inner-table">
          <div class="table-list-wrap">
            <table class="table-list table table-responsive table-striped">
              <thead>
                <tr>
                  <th class="coll-1 name">name</th>
                  <th class="coll-2">se</th>
                  <th class="coll-3">le</th>
                  <th class="coll-date">time</th>
                  <th class="coll-4"><span class="size">size</span> <span class="info">info</span></th>
                  <th class="coll-5">uploader</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="coll-1 name" style="padding-right: 56px;"><a href="/sub/80/0/" class="icon"><i class="flaticon-divx"></i></a><a href="/torrent/3668559/HorribleSubs-Boruto-Naruto-Next-Generations-99-720p-mkv/">[HorribleSubs] Boruto - Naruto Next Generations - 99 [720p].mkv</a><span class="comments"><i class="flaticon-message"></i>1</span></td>
                  <td class="coll-2 seeds">631</td>
                  <td class="coll-3 leeches">49</td>
                  <td class="coll-date">Mar. 24th '19</td>
                  <td class="coll-4 size mob-vip">453.6 MB<span class="seeds">631</span></td>
                  <td class="coll-5 vip"><a href="/user/EroRambos/">EroRambos</a></td>
                </tr>
                <tr>
                  <td class="coll-1 name"><a href="/sub/80/0/" class="icon"><i class="flaticon-divx"></i></a><a href="/torrent/3784004/HorribleSubs-Boruto-Naruto-Next-Generations-108-1080p-mkv/">[HorribleSubs] Boruto - Naruto Next Generations - 108 [1080p].mkv</a></td>
                  <td class="coll-2 seeds">471</td>
                  <td class="coll-3 leeches">17</td>
                  <td class="coll-date">May. 26th '19</td>
                  <td class="coll-4 size mob-vip">839.5 MB<span class="seeds">471</span></td>
                  <td class="coll-5 vip"><a href="/user/EroRambos/">EroRambos</a></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="pagination">
            <ul>
              <li class="active"><a href="/search/naruto/1/">1</a></li>
              <li><a href="/search/naruto/2/">2</a></li>
              <li><a href="/search/naruto/2/">&gt;&gt;</a></li>
              <li class="last"><a href="/search/naruto/50/">Last</a></li>
            </ul>
          </div>
        </div>
        "#;

        let (torrents, pagination) = O337xCategories::parse_html(sample_html).unwrap();
        assert_eq!(torrents.len(), 2);

        let t1 = &torrents[0];
        assert_eq!(
            t1.name,
            "[HorribleSubs] Boruto - Naruto Next Generations - 99 [720p].mkv"
        );
        assert_eq!(t1.info_hash, "3668559");
        assert_eq!(t1.source_url, Some("https://1337x.to/torrent/3668559/HorribleSubs-Boruto-Naruto-Next-Generations-99-720p-mkv/".to_string()));
        assert_eq!(t1.seeders, "631");
        assert_eq!(t1.leechers, "49");
        assert_eq!(t1.date, "Mar. 24th '19");
        assert_eq!(t1.size, "453.6 MB");
        assert_eq!(t1.total_downloads, "N/A");

        let t2 = &torrents[1];
        assert_eq!(
            t2.name,
            "[HorribleSubs] Boruto - Naruto Next Generations - 108 [1080p].mkv"
        );
        assert_eq!(t2.info_hash, "3784004");
        assert_eq!(t2.seeders, "471");
        assert_eq!(t2.leechers, "17");
        assert_eq!(t2.date, "May. 26th '19");
        assert_eq!(t2.size, "839.5 MB");

        assert_eq!(pagination.current_page, Some(1));
        assert_eq!(pagination.previous_page, None);
        assert_eq!(pagination.next_page, Some(2));
    }

    #[test]
    fn test_parse_detail_page_leetx() {
        let detail_html = r#"
        <div class="box-info torrent-detail-page  ">
          <div class="box-info-heading clearfix"><h1> [HorribleSubs] Boruto - Naruto Next Generations - 99 [720p].mkv </h1></div>
          <div class="l2e17a2aaa11cb03c4ab1cf50d8bd0f44f0776990 no-top-radius">
            <div class="l96cd2a49874095b4f3044fe94b6eb9ef04d8581c clearfix">
              <ul class="l429767559b5d2d55bdea84a3ecb61264095eb8ed l9c0dd0b978d3bb227faaff2d8edd3b01873d442d">
                <li><a class="l89497c07d0fb4bea2db3d9e001f6af4cd4348d90" href="magnet:?xt=urn:btih:10AD2B5E9BBFEBB0F9F13551E60E3728F860A120&amp;dn=%5BHorribleSubs%5D+Boruto+-+Naruto+Next+Generations+-+99+%5B720p%5D.mkv&amp;tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce"><span class="icon"></span>Magnet Download</a> </li>
              </ul>
            </div>
            <div class="manage-box">
              <div class="infohash-box">
                <p> <strong>Infohash :</strong> <span>10AD2B5E9BBFEBB0F9F13551E60E3728F860A120</span></p>
              </div>
            </div>
          </div>
        </div>
        "#;

        let (magnet, info_hash) = O337xCategories::parse_detail_page(detail_html);
        assert_eq!(
            magnet,
            "magnet:?xt=urn:btih:10AD2B5E9BBFEBB0F9F13551E60E3728F860A120&dn=%5BHorribleSubs%5D+Boruto+-+Naruto+Next+Generations+-+99+%5B720p%5D.mkv&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce"
        );
        assert_eq!(info_hash, "10AD2B5E9BBFEBB0F9F13551E60E3728F860A120");
    }
}
