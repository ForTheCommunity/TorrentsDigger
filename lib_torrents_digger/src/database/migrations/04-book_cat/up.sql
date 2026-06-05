-- created bookmark_categories table;
CREATE TABLE bookmark_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- adding 'Uncategorized'
INSERT INTO bookmark_categories (id,name) VALUES (0,'Uncategorized');

-- added category column;
ALTER TABLE bookmarked_torrents ADD COLUMN category_id INTEGER NOT NULL DEFAULT 0;
