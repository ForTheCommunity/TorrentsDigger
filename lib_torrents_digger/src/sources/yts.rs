use std::sync::Arc;
use anyhow::{Result, anyhow};
use core::fmt;
use scraper::{Html, Selector};
use ureq::{Body, http::Response};

use crate::{
    network_io::sync_request::{
        get_app_user_agent, get_client_agent, get_domain_cookie,
        send_request_with_agent,
    },
    prepare_info_hash,
    sources::{Pagination, QueryOptions},
    torrent::Torrent,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum YtsCategories {
    AllCategories,
    Action,
    Adventure,
    Animation,
    Biography,
    Comedy,
    Crime,
    Documentary,
    Drama,
    Family,
    Fantasy,
    FilmNoir,
    GameShow,
    History,
    Horror,
    Music,
    Musical,
    Mystery,
    News,
    RealityTv,
    Romance,
    SciFi,
    Sport,
    TalkShow,
    Thriller,
    War,
    Western,
}

impl YtsCategories {
    pub fn get_query_options() -> QueryOptions {
        QueryOptions {
            categories: true,
            filters: true,
            sortings: true,
            sorting_orders: false,
            pagination: true,
        }
    }

    const ALL_VARIANTS: &'static [YtsCategories] = &[
        Self::AllCategories,
        Self::Action,
        Self::Adventure,
        Self::Animation,
        Self::Biography,
        Self::Comedy,
        Self::Crime,
        Self::Documentary,
        Self::Drama,
        Self::Family,
        Self::Fantasy,
        Self::FilmNoir,
        Self::GameShow,
        Self::History,
        Self::Horror,
        Self::Music,
        Self::Musical,
        Self::Mystery,
        Self::News,
        Self::RealityTv,
        Self::Romance,
        Self::SciFi,
        Self::Sport,
        Self::TalkShow,
        Self::Thriller,
        Self::War,
        Self::Western,
    ];

    pub fn from_index(index: usize) -> Option<&'static YtsCategories> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_categories() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|c| c.to_string()).collect()
    }

    pub fn category_to_value(&self) -> &'static str {
        match self {
            Self::AllCategories => "all",
            Self::Action => "action",
            Self::Adventure => "adventure",
            Self::Animation => "animation",
            Self::Biography => "biography",
            Self::Comedy => "comedy",
            Self::Crime => "crime",
            Self::Documentary => "documentary",
            Self::Drama => "drama",
            Self::Family => "family",
            Self::Fantasy => "fantasy",
            Self::FilmNoir => "film-noir",
            Self::GameShow => "game-show",
            Self::History => "history",
            Self::Horror => "horror",
            Self::Music => "music",
            Self::Musical => "musical",
            Self::Mystery => "mystery",
            Self::News => "news",
            Self::RealityTv => "reality-tv",
            Self::Romance => "romance",
            Self::SciFi => "sci-fi",
            Self::Sport => "sport",
            Self::TalkShow => "talk-show",
            Self::Thriller => "thriller",
            Self::War => "war",
            Self::Western => "western",
        }
    }

    pub fn request_url_builder(
        torrent_name: &str,
        filter: &YtsFilters,
        category: &YtsCategories,
        sorting: &YtsSortings,
        page_number: &i64,
    ) -> String {
        let clean_name = torrent_name.trim();
        let query_param = if clean_name.is_empty() {
            "0".to_string()
        } else {
            urlencoding::encode(clean_name).to_string()
        };

        let quality = filter.filter_to_value();
        let genre = category.category_to_value();
        let order_by = sorting.sorting_to_value();
        let rating = "0";
        let year = "0";
        let language = "all";

        let mut url = format!(
            "https://yts.gg/browse-movies/{}/{}/{}/{}/{}/{}/{}",
            query_param, quality, genre, rating, order_by, year, language
        );

        if *page_number > 1 {
            url = format!("{}?page={}", url, page_number);
        }

        url
    }

    pub fn scrape_and_parse(mut response: Response<Body>) -> Result<(Vec<Torrent>, Pagination)> {
        let html = response
            .body_mut()
            .read_to_string()
            .map_err(|e| anyhow!("Error reading response body: {}", e))?;

        let (movies, pagination) = Self::parse_browse_page(&html)?;
        let torrents = Self::populate_torrents_from_detail_pages(movies);
        Ok((torrents, pagination))
    }

    pub fn parse_browse_page(html: &str) -> Result<(Vec<MovieCard>, Pagination)> {
        let document = Html::parse_document(html);

        let wrap_selector = Selector::parse("div.browse-movie-wrap")
            .map_err(|e| anyhow!("Invalid selector for wrap: {}", e))?;
        let title_selector = Selector::parse("a.browse-movie-title")
            .map_err(|e| anyhow!("Invalid selector for title: {}", e))?;
        let link_selector = Selector::parse("a.browse-movie-link")
            .map_err(|e| anyhow!("Invalid selector for link: {}", e))?;
        let year_selector = Selector::parse("div.browse-movie-year")
            .map_err(|e| anyhow!("Invalid selector for year: {}", e))?;
        let rating_selector = Selector::parse("h4.rating")
            .map_err(|e| anyhow!("Invalid selector for rating: {}", e))?;

        let mut movies = Vec::new();

        for wrap in document.select(&wrap_selector) {
            let mut title = wrap
                .select(&title_selector)
                .next()
                .map(|el| el.text().collect::<Vec<_>>().join(" ").trim().to_string())
                .unwrap_or_default();

            let href = wrap
                .select(&title_selector)
                .next()
                .or_else(|| wrap.select(&link_selector).next())
                .and_then(|el| el.value().attr("href"))
                .unwrap_or_default();

            if title.is_empty() {
                title = wrap
                    .select(&link_selector)
                    .next()
                    .and_then(|el| el.value().attr("title"))
                    .unwrap_or_default()
                    .to_string();
            }

            let detail_url = if href.starts_with('/') {
                format!("https://yts.gg{}", href)
            } else if href.starts_with("http") {
                href.to_string()
            } else {
                format!("https://yts.gg/{}", href)
            };

            let year = wrap
                .select(&year_selector)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_default();

            let rating = wrap
                .select(&rating_selector)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_default();

            if !detail_url.is_empty() && (!title.is_empty() || !href.is_empty()) {
                movies.push(MovieCard {
                    title,
                    year,
                    detail_url,
                    rating,
                });
            }
        }

        let pagination = Self::parse_pagination(&document);
        Ok((movies, pagination))
    }

    fn parse_pagination(document: &Html) -> Pagination {
        let mut pagination = Pagination {
            previous_page: None,
            current_page: Some(1),
            next_page: None,
        };

        let pagination_selector = match Selector::parse("ul.tsc_pagination li") {
            Ok(s) => s,
            Err(_) => return pagination,
        };

        let current_selector = match Selector::parse("a.current") {
            Ok(s) => s,
            Err(_) => return pagination,
        };

        for li in document.select(&pagination_selector) {
            let text = li.text().collect::<String>();
            let text_trim = text.trim();

            if let Some(a) = li.select(&current_selector).next() {
                if let Ok(cur) = a.text().collect::<String>().trim().parse::<i32>() {
                    pagination.current_page = Some(cur);
                }
            } else if text_trim.starts_with("Page ") {
                let page_str = text_trim.trim_start_matches("Page ").trim();
                if let Ok(cur) = page_str.parse::<i32>() {
                    pagination.current_page = Some(cur);
                }
            }

            if text_trim.contains("Next") {
                if let Ok(a_sel) = Selector::parse("a") {
                    if let Some(a) = li.select(&a_sel).next() {
                        if let Some(href) = a.value().attr("href") {
                            if let Some(page) = Self::extract_page_number_from_href(href) {
                                pagination.next_page = Some(page);
                            }
                        }
                    }
                }
            }

            if text_trim.contains("Previous") || text_trim == "«" {
                if !li.value().classes().any(|c| c == "hidden") {
                    if let Ok(a_sel) = Selector::parse("a") {
                        if let Some(a) = li.select(&a_sel).next() {
                            if let Some(href) = a.value().attr("href") {
                                if let Some(page) = Self::extract_page_number_from_href(href) {
                                    pagination.previous_page = Some(page);
                                }
                            }
                        }
                    }
                }
            }
        }

        if let Some(cur) = pagination.current_page {
            if pagination.next_page.is_none() {
                for li in document.select(&pagination_selector) {
                    if let Ok(a_sel) = Selector::parse("a") {
                        if let Some(a) = li.select(&a_sel).next() {
                            if let Ok(num) = a.text().collect::<String>().trim().parse::<i32>() {
                                if num == cur + 1 {
                                    pagination.next_page = Some(num);
                                }
                            }
                        }
                    }
                }
            }
            if cur > 1 && pagination.previous_page.is_none() {
                pagination.previous_page = Some(cur - 1);
            }
        }

        pagination
    }

    fn extract_page_number_from_href(href: &str) -> Option<i32> {
        let after_page = href.split("page=").nth(1)?;
        let num_str: String = after_page.chars().take_while(|c| c.is_ascii_digit()).collect();
        num_str.parse::<i32>().ok()
    }

    pub fn parse_detail_page(
        html: &str,
        movie: &MovieCard,
    ) -> Vec<Torrent> {
        let document = Html::parse_document(html);

        let modal_torrent_sel = match Selector::parse("div.modal-torrent") {
            Ok(s) => s,
            Err(_) => return Vec::new(),
        };
        let modal_quality_sel = match Selector::parse("div.modal-quality span") {
            Ok(s) => s,
            Err(_) => return Vec::new(),
        };
        let quality_size_sel = match Selector::parse("p.quality-size") {
            Ok(s) => s,
            Err(_) => return Vec::new(),
        };
        let magnet_sel = match Selector::parse("a.magnet-download, a[href^=\"magnet:\"]") {
            Ok(s) => s,
            Err(_) => return Vec::new(),
        };
        let download_btn_sel = match Selector::parse("a.download-torrent") {
            Ok(s) => s,
            Err(_) => return Vec::new(),
        };

        // Parse seeds from tech specs if present
        let mut seeds_list = Vec::new();
        if let Ok(tech_info_sel) = Selector::parse("div.tech-spec-info") {
            if let Ok(seeds_sel) = Selector::parse("span.tech-peers-seeds, span[title=\"Seeds\"]") {
                for tech_elem in document.select(&tech_info_sel) {
                    if let Some(span) = tech_elem.select(&seeds_sel).next() {
                        if let Some(parent) = span.parent().and_then(scraper::ElementRef::wrap) {
                            let text = parent.text().collect::<Vec<_>>().join(" ");
                            let seeds_val = text
                                .replace("Seeds", "")
                                .replace('\n', " ")
                                .trim()
                                .to_string();
                            seeds_list.push(seeds_val);
                        }
                    }
                }
            }
        }

        let mut torrents = Vec::new();

        for (idx, modal_elem) in document.select(&modal_torrent_sel).enumerate() {
            let quality = modal_elem
                .select(&modal_quality_sel)
                .next()
                .map(|el| el.text().collect::<String>().trim().to_string())
                .unwrap_or_default();

            let quality_sizes: Vec<String> = modal_elem
                .select(&quality_size_sel)
                .map(|el| el.text().collect::<String>().trim().to_string())
                .collect();

            let type_str = quality_sizes.first().cloned().unwrap_or_default();
            let size = if quality_sizes.len() > 1 {
                quality_sizes[1].clone()
            } else {
                quality_sizes.first().cloned().unwrap_or_default()
            };

            let magnet = modal_elem
                .select(&magnet_sel)
                .next()
                .and_then(|el| el.value().attr("href"))
                .unwrap_or_default()
                .to_string();

            let download_url = modal_elem
                .select(&download_btn_sel)
                .next()
                .and_then(|el| el.value().attr("href"))
                .unwrap_or_default()
                .to_string();

            let info_hash = prepare_info_hash(&magnet).unwrap_or_else(|_| {
                download_url
                    .split("/torrent/download/")
                    .nth(1)
                    .unwrap_or_default()
                    .to_lowercase()
            });

            // Extract display name from dn in magnet, or fallback to formatted title
            let name = if let Some(dn_part) = magnet.split("&dn=").nth(1) {
                let encoded_name = dn_part.split('&').next().unwrap_or_default();
                let with_spaces = encoded_name.replace('+', " ");
                urlencoding::decode(&with_spaces)
                    .map(|s| s.into_owned())
                    .unwrap_or_else(|_| with_spaces)
            } else if !quality.is_empty() && !type_str.is_empty() {
                format!("{} ({}) [{} {}]", movie.title, movie.year, quality, type_str)
            } else if !quality.is_empty() {
                format!("{} ({}) [{}]", movie.title, movie.year, quality)
            } else {
                format!("{} ({})", movie.title, movie.year)
            };

            let seeders = seeds_list
                .get(idx)
                .filter(|s| !s.is_empty())
                .cloned()
                .unwrap_or_else(|| "0".to_string());

            torrents.push(Torrent {
                info_hash,
                name,
                magnet,
                size,
                date: movie.year.clone(),
                seeders,
                leechers: "0".to_string(),
                total_downloads: "0".to_string(),
                source_url: Some(movie.detail_url.clone()),
            });
        }

        // If no modal torrents were found on the page, create a fallback entry
        if torrents.is_empty() {
            torrents.push(Torrent {
                info_hash: String::new(),
                name: format!("{} ({})", movie.title, movie.year),
                magnet: String::new(),
                size: String::new(),
                date: movie.year.clone(),
                seeders: "0".to_string(),
                leechers: "0".to_string(),
                total_downloads: "0".to_string(),
                source_url: Some(movie.detail_url.clone()),
            });
        }

        torrents
    }

    pub fn populate_torrents_from_detail_pages(movies: Vec<MovieCard>) -> Vec<Torrent> {
        if movies.is_empty() {
            return Vec::new();
        }

        let agent = match get_client_agent() {
            Ok(a) => Arc::new(a),
            Err(_) => {
                return movies
                    .into_iter()
                    .map(|m| Torrent {
                        info_hash: String::new(),
                        name: format!("{} ({})", m.title, m.year),
                        magnet: String::new(),
                        size: String::new(),
                        date: m.year,
                        seeders: "0".to_string(),
                        leechers: "0".to_string(),
                        total_downloads: "0".to_string(),
                        source_url: Some(m.detail_url),
                    })
                    .collect();
            }
        };

        let user_agent = Arc::new(get_app_user_agent());
        let cookie = Arc::new(get_domain_cookie("yts.gg"));

        let num_workers = 10.min(movies.len());
        let (job_tx, job_rx) = std::sync::mpsc::channel::<(usize, MovieCard)>();
        let (result_tx, result_rx) = std::sync::mpsc::channel::<(usize, Vec<Torrent>)>();
        let job_rx = Arc::new(std::sync::Mutex::new(job_rx));

        for (idx, movie) in movies.into_iter().enumerate() {
            let _ = job_tx.send((idx, movie));
        }
        drop(job_tx);

        let mut handles = Vec::new();
        for _ in 0..num_workers {
            let rx = Arc::clone(&job_rx);
            let r_tx = result_tx.clone();
            let agent = Arc::clone(&agent);
            let ua = Arc::clone(&user_agent);
            let ck = Arc::clone(&cookie);

            let handle = std::thread::spawn(move || {
                loop {
                    let job = {
                        let Ok(lock) = rx.lock() else { break };
                        lock.recv().ok()
                    };
                    let Some((idx, movie)) = job else { break };

                    if let Ok(mut res) = send_request_with_agent(&agent, &movie.detail_url, &ua, ck.as_deref()) {
                        if let Ok(html) = res.body_mut().read_to_string() {
                            let parsed = Self::parse_detail_page(&html, &movie);
                            let _ = r_tx.send((idx, parsed));
                            continue;
                        }
                    }

                    // Fallback on request failure
                    let fallback = vec![Torrent {
                        info_hash: String::new(),
                        name: format!("{} ({})", movie.title, movie.year),
                        magnet: String::new(),
                        size: String::new(),
                        date: movie.year,
                        seeders: "0".to_string(),
                        leechers: "0".to_string(),
                        total_downloads: "0".to_string(),
                        source_url: Some(movie.detail_url),
                    }];
                    let _ = r_tx.send((idx, fallback));
                }
            });
            handles.push(handle);
        }
        drop(result_tx);

        let mut collected: Vec<(usize, Vec<Torrent>)> = Vec::new();
        while let Ok((idx, torrents)) = result_rx.recv() {
            collected.push((idx, torrents));
        }

        for h in handles {
            let _ = h.join();
        }

        collected.sort_by_key(|(idx, _)| *idx);
        collected.into_iter().flat_map(|(_, list)| list).collect()
    }
}

impl fmt::Display for YtsCategories {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::AllCategories => write!(f, "All"),
            Self::Action => write!(f, "Action"),
            Self::Adventure => write!(f, "Adventure"),
            Self::Animation => write!(f, "Animation"),
            Self::Biography => write!(f, "Biography"),
            Self::Comedy => write!(f, "Comedy"),
            Self::Crime => write!(f, "Crime"),
            Self::Documentary => write!(f, "Documentary"),
            Self::Drama => write!(f, "Drama"),
            Self::Family => write!(f, "Family"),
            Self::Fantasy => write!(f, "Fantasy"),
            Self::FilmNoir => write!(f, "Film-Noir"),
            Self::GameShow => write!(f, "Game-Show"),
            Self::History => write!(f, "History"),
            Self::Horror => write!(f, "Horror"),
            Self::Music => write!(f, "Music"),
            Self::Musical => write!(f, "Musical"),
            Self::Mystery => write!(f, "Mystery"),
            Self::News => write!(f, "News"),
            Self::RealityTv => write!(f, "Reality-TV"),
            Self::Romance => write!(f, "Romance"),
            Self::SciFi => write!(f, "Sci-Fi"),
            Self::Sport => write!(f, "Sport"),
            Self::TalkShow => write!(f, "Talk-Show"),
            Self::Thriller => write!(f, "Thriller"),
            Self::War => write!(f, "War"),
            Self::Western => write!(f, "Western"),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum YtsFilters {
    AllFilters,
    Q480p,
    Q720p,
    Q1080p,
    Q1080pX265,
    Q2160p,
    Q3D,
}

impl YtsFilters {
    const ALL_VARIANTS: &'static [YtsFilters] = &[
        Self::AllFilters,
        Self::Q480p,
        Self::Q720p,
        Self::Q1080p,
        Self::Q1080pX265,
        Self::Q2160p,
        Self::Q3D,
    ];

    pub fn from_index(index: usize) -> Option<&'static YtsFilters> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_filters() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|f| f.to_string()).collect()
    }

    pub fn filter_to_value(&self) -> &'static str {
        match self {
            Self::AllFilters => "all",
            Self::Q480p => "480p",
            Self::Q720p => "720p",
            Self::Q1080p => "1080p",
            Self::Q1080pX265 => "1080p.x265",
            Self::Q2160p => "2160p",
            Self::Q3D => "3D",
        }
    }
}

impl fmt::Display for YtsFilters {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::AllFilters => write!(f, "All"),
            Self::Q480p => write!(f, "480p"),
            Self::Q720p => write!(f, "720p"),
            Self::Q1080p => write!(f, "1080p"),
            Self::Q1080pX265 => write!(f, "1080p.x265"),
            Self::Q2160p => write!(f, "2160p"),
            Self::Q3D => write!(f, "3D"),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum YtsSortings {
    Latest,
    Oldest,
    Featured,
    Seeds,
    Peers,
    Year,
    Rating,
    Likes,
    RtAudience,
    Alphabetical,
    Downloads,
}

impl YtsSortings {
    const ALL_VARIANTS: &'static [YtsSortings] = &[
        Self::Latest,
        Self::Oldest,
        Self::Featured,
        Self::Seeds,
        Self::Peers,
        Self::Year,
        Self::Rating,
        Self::Likes,
        Self::RtAudience,
        Self::Alphabetical,
        Self::Downloads,
    ];

    pub fn from_index(index: usize) -> Option<&'static YtsSortings> {
        Self::ALL_VARIANTS.get(index)
    }

    pub fn all_yts_sortings() -> Vec<String> {
        Self::ALL_VARIANTS.iter().map(|s| s.to_string()).collect()
    }

    pub fn sorting_to_value(&self) -> &'static str {
        match self {
            Self::Latest => "latest",
            Self::Oldest => "oldest",
            Self::Featured => "featured",
            Self::Seeds => "seeds",
            Self::Peers => "peers",
            Self::Year => "year",
            Self::Rating => "rating",
            Self::Likes => "likes",
            Self::RtAudience => "rt_audience",
            Self::Alphabetical => "alphabetical",
            Self::Downloads => "downloads",
        }
    }
}

impl fmt::Display for YtsSortings {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Latest => write!(f, "Latest"),
            Self::Oldest => write!(f, "Oldest"),
            Self::Featured => write!(f, "Featured"),
            Self::Seeds => write!(f, "Seeds"),
            Self::Peers => write!(f, "Peers"),
            Self::Year => write!(f, "Year"),
            Self::Rating => write!(f, "IMDb Rating"),
            Self::Likes => write!(f, "YTS Likes"),
            Self::RtAudience => write!(f, "RT Audience"),
            Self::Alphabetical => write!(f, "Alphabetical"),
            Self::Downloads => write!(f, "Downloads"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct MovieCard {
    pub title: String,
    pub year: String,
    pub detail_url: String,
    pub rating: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_request_builder_yts() {
        let url = YtsCategories::request_url_builder(
            "john wick",
            &YtsFilters::AllFilters,
            &YtsCategories::AllCategories,
            &YtsSortings::Latest,
            &1,
        );
        assert_eq!(
            url,
            "https://yts.gg/browse-movies/john%20wick/all/all/0/latest/0/all"
        );

        let url_page = YtsCategories::request_url_builder(
            "avengers",
            &YtsFilters::AllFilters,
            &YtsCategories::AllCategories,
            &YtsSortings::Latest,
            &2,
        );
        assert_eq!(
            url_page,
            "https://yts.gg/browse-movies/avengers/all/all/0/latest/0/all?page=2"
        );

        let url_4k = YtsCategories::request_url_builder(
            "",
            &YtsFilters::Q2160p,
            &YtsCategories::AllCategories,
            &YtsSortings::Seeds,
            &1,
        );
        assert_eq!(
            url_4k,
            "https://yts.gg/browse-movies/0/2160p/all/0/seeds/0/all"
        );
    }

    #[test]
    fn test_parse_browse_page_yts() {
        let sample_html = r#"
        <div class="browse-content">
            <div class="container">
                <section>
                    <div class="row">
                        <div class="browse-movie-wrap col-xs-10 col-sm-4 col-md-5 col-lg-4">
                            <a href="https://yts.gg/movies/the-avenger-2024" class="browse-movie-link">
                                <figure>
                                    <img class="img-responsive" src="https://img.yts.gg/the_avenger.jpg" alt="The Avenger (2024) download">
                                    <figcaption>
                                        <h4 class="rating">4.2 / 10</h4>
                                        <h4>Action</h4>
                                    </figcaption>
                                </figure>
                            </a>
                            <div class="browse-movie-bottom">
                                <a href="https://yts.gg/movies/the-avenger-2024" class="browse-movie-title">The Avenger</a>
                                <div class="browse-movie-year">2024</div>
                            </div>
                        </div>
                    </div>
                </section>
                <div class="hidden-sm hidden-xs">
                    <ul class="tsc_pagination tsc_paginationA tsc_paginationA06">
                        <li class="hidden"><a href="">«</a></li>
                        <li><a href="javascript:void(0)" class="current">1</a></li>
                        <li><a href="/browse-movies/avengers/all/all/0/latest/0/all?page=2">2</a></li>
                        <li><a href="/browse-movies/avengers/all/all/0/latest/0/all?page=3">3</a></li>
                        <li><a href="/browse-movies/avengers/all/all/0/latest/0/all?page=2">Next »</a></li>
                    </ul>
                </div>
            </div>
        </div>
        "#;

        let (movies, pagination) = YtsCategories::parse_browse_page(sample_html).unwrap();
        assert_eq!(movies.len(), 1);
        assert_eq!(movies[0].title, "The Avenger");
        assert_eq!(movies[0].year, "2024");
        assert_eq!(movies[0].detail_url, "https://yts.gg/movies/the-avenger-2024");
        assert_eq!(pagination.current_page, Some(1));
        assert_eq!(pagination.next_page, Some(2));
    }

    #[test]
    fn test_parse_detail_page_yts() {
        let sample_detail_html = r#"
        <div class="modal modal-download hidden-xs hidden-sm">
            <div class="modal-container">
                <div class="modal-content">
                    <div class="modal-torrent">
                        <div class="modal-quality" id="modal-quality-720p"><span>720p</span></div>
                        <p class="quality-size">BluRay </p>
                        <br>
                        <p>File size</p>
                        <p class="quality-size">1.25 GB</p>
                        <a class="download-torrent" href="https://yts.gg/torrent/download/EA17E6BE92962A403AC1C638D2537DCF1E564D26">Download</a>
                        <a href="magnet:?xt=urn:btih:EA17E6BE92962A403AC1C638D2537DCF1E564D26&amp;dn=Avengers%3A+Infinity+War+%282018%29+%5B720p%5D+%5BYTS.GG%5D&amp;tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce" class="magnet-download download-torrent magnet"><span>Magnet</span></a>
                    </div>
                    <div class="modal-torrent">
                        <div class="modal-quality" id="modal-quality-1080p"><span>1080p</span></div>
                        <p class="quality-size">BluRay </p>
                        <br>
                        <p>File size</p>
                        <p class="quality-size">2.39 GB</p>
                        <a class="download-torrent" href="https://yts.gg/torrent/download/866BDCFA006930A718ADBC21D8CAE1F2C7F9D8B3">Download</a>
                        <a href="magnet:?xt=urn:btih:866BDCFA006930A718ADBC21D8CAE1F2C7F9D8B3&amp;dn=Avengers%3A+Infinity+War+%282018%29+%5B1080p%5D+%5BYTS.GG%5D&amp;tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce" class="magnet-download download-torrent magnet"><span>Magnet</span></a>
                    </div>
                </div>
            </div>
        </div>
        <div id="movie-tech-specs" class="row">
            <div class="tech-spec-info col-xs-20">
                <div class="tech-spec-element"><span title="Seeds" class="tech-peers-seeds">Seeds</span> 4 </div>
            </div>
            <div class="tech-spec-info col-xs-20">
                <div class="tech-spec-element"><span title="Seeds" class="tech-peers-seeds">Seeds</span> 38 </div>
            </div>
        </div>
        "#;

        let movie = MovieCard {
            title: "Avengers: Infinity War".to_string(),
            year: "2018".to_string(),
            detail_url: "https://yts.gg/movies/avengers-infinity-war-2018".to_string(),
            rating: "8.4 / 10".to_string(),
        };

        let torrents = YtsCategories::parse_detail_page(sample_detail_html, &movie);
        assert_eq!(torrents.len(), 2);
        assert_eq!(torrents[0].name, "Avengers: Infinity War (2018) [720p] [YTS.GG]");
        assert_eq!(torrents[0].info_hash, "ea17e6be92962a403ac1c638d2537dcf1e564d26");
        assert_eq!(torrents[0].size, "1.25 GB");
        assert_eq!(torrents[0].seeders, "4");

        assert_eq!(torrents[1].name, "Avengers: Infinity War (2018) [1080p] [YTS.GG]");
        assert_eq!(torrents[1].info_hash, "866bdcfa006930a718adbc21d8cae1f2c7f9d8b3");
        assert_eq!(torrents[1].size, "2.39 GB");
        assert_eq!(torrents[1].seeders, "38");
    }
}
