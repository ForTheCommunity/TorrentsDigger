// FRB is unable to translate Some Structs from external crate.
// so Mapping External Structs With Internal Structs,

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
