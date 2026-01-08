// FRB is unable to translate Some Structs from external crate.
// so Mapping External Structs With Internal Structs,
// this may be a skill issue of mine but
// will be resolved later once i knew correct way
// to handle this issue.

pub struct InternalTorrent {
    pub info_hash: String,
    pub name: String,
    pub magnet: String,
    pub size: String,
    pub date: String,
    pub seeders: String,
    pub leechers: String,
    pub total_downloads: String,
}

pub struct InternalSource {
    pub source_name: String,
    pub source_details: InternalSourceDetails,
}

pub struct InternalSourceDetails {
    pub query_options: InternalQueryOptions,
    pub categories: Vec<String>,
    pub source_filters: Vec<String>,
    pub source_sortings: Vec<String>,
    pub source_sorting_orders: Vec<String>,
}

pub struct InternalQueryOptions {
    pub categories: bool,
    pub filters: bool,
    pub sortings: bool,
    pub sorting_orders: bool,
    pub pagination: bool,
}

pub struct InternalProxy {
    pub id: i32,
    pub proxy_name: String,
    pub proxy_type: String,
    pub proxy_server_ip: String,
    pub proxy_server_port: String,
    pub proxy_username: Option<String>,
    pub proxy_password: Option<String>,
}

pub struct InternalCustomSourceDetails {
    pub custom_source_name: String,
    pub custom_source_listings: Vec<String>,
}

pub struct InternalPagination {
    pub previous_page: Option<i32>,
    pub current_page: Option<i32>,
    pub next_page: Option<i32>,
}
