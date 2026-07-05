-- Create bookmark tag table :
CREATE TABLE bookmark_tags (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Create Torrents Tags table :
CREATE TABLE torrent_tags (
    info_hash TEXT NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (info_hash,tag_id),
    FOREIGN KEY (info_hash) REFERENCES bookmarked_torrents(info_hash) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES bookmark_tags(id) ON DELETE CASCADE
);