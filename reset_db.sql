DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS candidates CASCADE;
DROP TABLE IF EXISTS elections CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS assigned_elections CASCADE;

CREATE TABLE users (
    email VARCHAR(255) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE elections (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    creator_email VARCHAR(255) REFERENCES users(email)
);

CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    election_id INT REFERENCES elections(id)
);

CREATE TABLE votes (
    id SERIAL PRIMARY KEY,
    election_id INT REFERENCES elections(id),
    candidate_id INT REFERENCES candidates(id),
    user_email VARCHAR(255) REFERENCES users(email)
);

CREATE TABLE assigned_elections (
    user_email VARCHAR(255) REFERENCES users(email),
    election_id INT REFERENCES elections(id),
    PRIMARY KEY (user_email, election_id)
);
