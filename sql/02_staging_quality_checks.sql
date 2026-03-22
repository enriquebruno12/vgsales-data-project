select count(*) from stg_vgsales_raw;

select * from stg_vgsales_raw limit 20;

-- Checking for missing years

	select
		count(*) as total,
		count(*) filter(where year is null) as year_nulls,
		round(100.0 * count(*) filter(where year is null) / count(*),2) as pct_year_null
		from stg_vgsales_raw;
	
	select * from stg_vgsales_raw where year is null;

-- Missing years by platform
	select 
		platform,
		count(*) as rows_total,
		count(*) filter(where year is null) as year_nulls,
		round(100.0 * count(*) filter(where year is null) / count(*),2) as pct_year_null
	from stg_vgsales_raw
	group by platform
	having count(*) filter (where year is null) > 0
	order by pct_year_null desc, year_nulls desc, rows_total desc
	limit 50;

--Missing years by publisher
	select 
		publisher,
		count(*) as rows_total,
		count(*) filter(where year is null) as year_nulls,
		round(100.0 * count(*) filter(where year is null) / count(*),2) as pct_year_null
	from stg_vgsales_raw
	group by publisher
	having count(*) filter (where year is null) > 0
	order by pct_year_null desc, year_nulls desc, rows_total desc;

--Checking for negative sales

	select
		count(*) as total,
		count(*) filter(where na_sales<0 or eu_sales<0 or jp_sales<0 or other_sales<0 or global_sales<0)
	from stg_vgsales_raw;
	
	select *
	from stg_vgsales_raw
	where na_sales<0 or eu_sales<0 or jp_sales<0 or other_sales<0 or global_sales<0
	limit 50;

-- Checking if Rank column has duplicates

	select rank, count(*)
	from stg_vgsales_raw
	group by rank
	having count(*) > 1
	order by 2 desc;

-- Checking if global sales is matching the sum up of other regions

	select *
	from stg_vgsales_raw
	where global_sales is not null
		and (na_sales is not null or eu_sales is not null or jp_sales is not null or other_sales is not null)
		and abs(
			global_sales - coalesce(na_sales,0) - coalesce(eu_sales,0) - coalesce(jp_sales,0) - coalesce(other_sales,0)
		) > 0.05
	limit 50;

-- Checking for duplicates on name, platform and year columns

	select name, platform, year, count(*) as cnt
	from stg_vgsales_raw
	group by name, platform, year
	having count(*) > 1
	order by cnt desc
	limit 50;
	
	select name, platform, count(*) as cnt
	from stg_vgsales_raw
	where year is null
	group by name, platform
	having count(*)>1
	order by cnt desc
	limit 50;
	
	--Checking if dulicates are indenticals or conflictings
		
		select name, platform, year,
			count(*) as cnt,
			min(global_sales) min_g,
			max(global_sales) max_g
		from stg_vgsales_raw
		group by name, platform, year
		having count(*) > 1
		order by cnt desc;

-- Checking for empty fields on text columns

	select
		count(*) filter(where name is null or trim(name)='') as name_missing,
		count(*) filter(where platform is null or trim(platform)='') as platfor_missing,
		count(*) filter(where genre is null or trim(genre)='') as genre_missing,
		count(*) filter(where publisher is null or trim(publisher)='') as publisher_missing
	from stg_vgsales_raw;

-- Checking for outliers
	
	select
		min(year) as min_year,
		max(year) as max_year
	from stg_vgsales_raw;
	
	select name, platform, year, global_sales
	from stg_vgsales_raw
	order by global_sales desc nulls last
	limit 20;

-- Checking for nulls by each column (general view)
	
	select
		count(*) as total,
		count(*) filter(where rank is null) as rank_nulls,
		count(*) filter(where name is null) as name_nulls,
		count(*) filter(where platform is null) as platform_nulls,
		count(*) filter(where genre is null) as genre_nulls,
		count(*) filter(where publisher is null) as publisher_nulls,
		count(*) filter (where global_sales is null) as global_sales_nulls
	from stg_vgsales_raw;
	