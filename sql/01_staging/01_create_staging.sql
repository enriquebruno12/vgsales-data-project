create schema if not exists staging;

CREATE table if not exists stg_vgsales_raw(
    rank INT,
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

select * from stg_vgsales_raw;

alter table stg_vgsales_raw
	set schema staging;