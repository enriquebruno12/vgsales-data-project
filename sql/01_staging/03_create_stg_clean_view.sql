-- Standardizing values
	create or replace view stg_vgsales_norm as
	select
		rank,
		nullif(trim(name),'') as name,
		nullif(trim(platform),'') as platform,
		year,
		nullif(trim(genre),'') as genre,
		nullif(trim(publisher),'') as publisher,
		na_sales,
		eu_sales,
		jp_sales,
		other_sales,
		global_sales
	from stg_vgsales_raw;

-- Checking if there are any null values for important attributes (name and platform)
	
	select count(*) as bad_keys
	from stg_vgsales_norm
	where name is null or platform is null;

-- Handling duplicates
	
	create or replace view stg_vgsales_clean as
	with ranked as (
		select
		n.*,
		count(*) over (partition by name, platform, year) as dup_count,
		row_number() over (
			partition by name, platform, year
			order by
				global_sales desc nulls last,
				(coalesce(na_sales,0) +   coalesce(eu_sales,0) + coalesce(jp_sales,0) + coalesce(other_sales,0)) desc,
				rank asc nulls last
		) as rn
		from stg_vgsales_norm n
		where name is not null and platform is not null
	)
	select
		rank, name, platform, year, genre, publisher,
		na_sales, eu_sales, jp_sales, other_sales, global_sales,
		dup_count
	from ranked
	where rn = 1;

-- How many registers left on dedup
	
	select
		(select count(*) from stg_vgsales_raw)  as raw_rows,
		(select count(*) from stg_vgsales_clean) as clean_rows,
		(select count(*) from stg_vgsales_raw) - (select count(*) from stg_vgsales_clean) as removed;
	
-- Is there any duplicates left?
	
	select name, platform, year, count(*) as cnt
	from stg_vgsales_clean
	group by name, platform, year
	having count(*) > 1;