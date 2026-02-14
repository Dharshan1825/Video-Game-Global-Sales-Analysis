-- Create table for game metadata
CREATE TABLE games (
    title VARCHAR(255) NOT NULL,        -- Game title
    release_date DATE,                  -- Exact release date
    team VARCHAR(255),                  -- Developer / Team name
    rating DECIMAL(3,2),                -- Rating like 4.5
    times_listed TEXT,                  -- Time listed by users
    no_of_reviews TEXT,                  -- Total reviews count
    genres VARCHAR(255),                -- Genre (e.g. Action, RPG)
    summary TEXT,                       -- Game summary/description
    reviews TEXT,                       -- Actual user reviews
    plays INT,                          -- Number of plays
    playing TEXT,                        -- Currently playing
    backlogs INT,                       -- Users with game in backlog
    wishlist INT,                       -- Users who wishlisted
    release_year INT                    -- Year of release only
);

-- Create table for vgsales data
CREATE TABLE vgsales (
    rank INT PRIMARY KEY,              -- Game rank
    name VARCHAR(255) NOT NULL,        -- Game name
    platform VARCHAR(50),              -- Platform (e.g. PS4, X360, PC)
    year INT,                          -- Release year
    genre VARCHAR(100),                -- Genre (Action, Sports, etc.)
    publisher VARCHAR(255),            -- Publisher name
    na_sales DECIMAL(6,2),             -- North America Sales (in millions)
    eu_sales DECIMAL(6,2),             -- Europe Sales (in millions)
    jp_sales DECIMAL(6,2),             -- Japan Sales (in millions)
    other_sales DECIMAL(6,2),          -- Other regions Sales (in millions)
    global_sales DECIMAL(7,2)          -- Global Sales (in millions)
);

-- Create merged table linking games and vgsales
-- Create merged table linking games and vgsales
CREATE TABLE game_sales_merged (
    merged_id SERIAL PRIMARY KEY,              -- Unique ID for merged records
    game_title VARCHAR(255) NOT NULL,          -- Game title (from games)
    game_id INT,                               -- FK reference to games (optional, if you add game_id later)
    vgsales_rank INT NOT NULL,                 -- FK from vgsales
    platform VARCHAR(50),                      -- Platform info from vgsales
    genre VARCHAR(100),                        -- Genre info
    publisher VARCHAR(255),                    -- Publisher info
    release_year INT,                          -- Common release year
    rating DECIMAL(3,2),                       -- Game rating
    global_sales DECIMAL(7,2),                 -- Total sales (in millions)
    plays INT,                                 -- Plays count from games
    wishlist INT,                              -- Wishlist count from games
    merge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of merge

    -- Foreign key constraint linking vgsales table
    CONSTRAINT fk_vgsales
        FOREIGN KEY (vgsales_rank)
        REFERENCES vgsales (rank)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

COPY games(
    title, release_date, team, rating, times_listed,
    no_of_reviews, genres, summary, reviews,
    plays, playing, backlogs, wishlist, release_year
)
FROM 'C:\\Program Files\\PostgreSQL\\17\\data\\games.csv'
DELIMITER ',' 
CSV HEADER 
ENCODING 'UTF8';

SELECT COUNT(*) FROM games;
SELECT COUNT(*) FROM vgsales;

INSERT INTO game_sales_merged (
    game_title, vgsales_rank, platform, genre, publisher,
    release_year, rating, global_sales, plays, wishlist
)
SELECT 
    g.title,
    v.rank,
    v.platform,
    v.genre,
    v.publisher,
    g.release_year,
    g.rating,
    v.global_sales,
    g.plays,
    g.wishlist
FROM games g
JOIN vgsales v
    ON LOWER(g.title) = LOWER(v.name)
   AND g.release_year = v.year;


SELECT COUNT(*) FROM game_sales_merged;
SELECT * FROM game_sales_merged LIMIT 10;

SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_name = 'game_sales_merged';

