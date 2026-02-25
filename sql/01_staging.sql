CREATE TABLE stg_vgsales_raw(
    game_rank INT,
    name varchar(255),
    platform TEXT,
    year int,
    genre varchar(255),
    publisher varchar(255),
    na_sales NUMERIC,
    eu_sales NUMERIC,
    jp_sales NUMERIC,
    other_sales NUMERIC,
    global_sales NUMERIC
);