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

pub struct InternalQueryOptions {
    pub categories: bool,
    pub sortings: bool,
    pub filters: bool,
}

pub struct InternalSourceDetails {
    pub query_options: InternalQueryOptions,
    pub categories: Vec<String>,
    pub source_filters: Vec<String>,
    pub source_sortings: Vec<String>,
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
