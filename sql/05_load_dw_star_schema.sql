begin;

-- 0) Cleaning DW for full reload (dev enviroment)

truncate table
	dw.fact_sales,
	dw.dim_game,
	dw.dim_platform,
	dw.dim_genre,
	dw.dim_publisher
RESTART identity CASCADE;

-- 1) Ensure 'Unknown' in lookup dimensions

insert into dw.dim_platform (platform)
values('Unknown')
on conflict (platform) do nothing;

insert into dw.dim_genre (genre)
values('Unknown')
on conflict (genre) do nothing;

insert into dw.dim_publisher (publisher)
values('Unknown')
on conflict (publisher) do nothing;

-- 2) Loading lookup dimensions

insert into dw.dim_platform (platform)
select distinct platform
from staging.stg_vgsales_clean
where platform is not null
on conflict (platform) do nothing;

insert into dw.dim_genre(genre)
select distinct genre
from staging.stg_vgsales_clean
where genre is not null
on conflict (genre) do nothing;

insert into dw.dim_publisher (publisher)
select distinct publisher
from staging.stg_vgsales_clean
where publisher is not null
on conflict (publisher) do nothing;

-- 3) Loading dim_game
-- Grain: 1 row per (game, platform_id,year_key)

insert into dw.dim_game(
	game,
	year,
	rank,
	platform_id,
	genre_id,
	publisher_id
)
select
	c.name as game,
	c.year,
	c.rank,
	p.platform_id,
	g.genre_id,
	pub.publisher_id
from staging.stg_vgsales_clean c
left join dw.dim_platform p
	on p.platform = coalesce(c.platform, 'Unknown')
left join dw.dim_genre g
	on g.genre = coalesce(c.genre, 'Unknown')
left join dw.dim_publisher pub
	on pub.publisher = coalesce(c.publisher, 'Unknown')
where c.name is not null
on conflict (game, platform_id, year_key) do nothing;


-- 4) Loading fact_sales

insert into dw.fact_sales(
	game_id,
	na_sales,
	eu_sales,
	jp_sales,
	other_sales,
	global_sales
)
select
	dg.game_id,
	coalesce(c.na_sales,0) as na_sales,
	coalesce(c.eu_sales, 0) as eu_sales,
	coalesce(c.jp_sales, 0) as jp_sales,
	coalesce(c.other_sales, 0) as other_sales,
	coalesce(c.global_sales, 0) as global_sales
from staging.stg_vgsales_clean c
join dw.dim_platform p
	on p.platform = coalesce(c.platform,'Unknown')
join dw.dim_game dg
	on dg.game = c.name
	and dg.platform_id = p.platform_id
	and dg.year_key = coalesce(c.year,-1)
on conflict (game_id) do update
set
	na_sales = excluded.na_sales,
	eu_sales = excluded.eu_sales,
	jp_sales = excluded.jp_sales,
	other_sales = excluded.other_sales,
	global_sales = excluded.global_sales;

/*
-- Validating ...


-- Checking number of rows per table.
SELECT 'stg_clean' AS layer, COUNT(*) AS row_count
FROM staging.stg_vgsales_clean

UNION ALL

SELECT 'dim_game' AS layer, COUNT(*) AS row_count
FROM dw.dim_game

UNION ALL

SELECT 'fact_sales' AS layer, COUNT(*) AS row_count
FROM dw.fact_sales;

-- Checking for oprhan facts

select count(*) as orphan_facts
from dw.fact_sales f
left join dw.dim_game g
	on g.game_id = f.game_id
where g.game_id is null;


-- Checking for duplicates in dim_game
select
	game,
	platform_id,
	year_key,
	count(*) as qty
from dw.dim_game
group by game, platform_id, year_key
having count(*) > 1;

-- Comparing global sales
select
	round((select coalesce(global_sales,0) :: numeric from staging.stg_vgsales_clean),2) as stg_clean_global,
	round((select coalesce(global_sales,0) :: numeric from dw.fact_sales),2) as fact_global;

-- Top 10 Sanity Check
select
	dg.game,
	p.platform,
	dg.year,
	f.global_sales
from dw.fact_sales f
join dw.dim_game dg
	on dg.game_id = f.game_id
join dw.dim_platform p
	p.platform_id = dg.platform_id
order by f.global_sales desc nulls last
limit 10;
*/
--rollback;

commit;