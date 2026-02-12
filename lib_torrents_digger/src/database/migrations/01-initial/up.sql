-- Table for storing Bookmarked Torrents...
CREATE TABLE IF NOT EXISTS bookmarked_torrents (
	info_hash TEXT UNIQUE,
	name TEXT,
	magnet TEXT,
	size TEXT,
	date TEXT,
	seeders TEXT,
	leechers TEXT,
	total_downloads TEXT
);

-- Table for storing Proxy Details...
CREATE TABLE IF NOT EXISTS proxy_table (
	id INTEGER PRIMARY KEY,
	proxy_name VARCHAR(255) NOT NULL,
	proxy_type VARCHAR(255) NOT NULL,
	proxy_server_ip VARCHAR(255) NOT NULL,
	proxy_server_port VARCHAR(255) NOT NULL,
	proxy_username VARCHAR(255),
	proxy_password VARCHAR(255)
);

-- Table for storing Settings KEY-VALUE...
CREATE TABLE IF NOT EXISTS settings_kvs (
	key TEXT PRIMARY KEY,
	value TEXT
);

-- Inserting Default Key Value in Settings Key-Value Store...
INSERT OR IGNORE INTO settings_kvs (key, value) VALUES ('active_trackers_list', '0');
