-- SQLite
CREATE TABLE user(
    user_id INTEGER PRIMARY KEY,
    user_name TEXT,
    email TEXT UNIQUE,
    password TEXT
);

