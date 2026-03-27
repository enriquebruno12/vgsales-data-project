create or replace view dw.vw_sales_enriched as
select
	f.game_id,
	dg.game,
	p.platform,
	g.genre,
	pub.publisher,
	dg.year,
	case
		when dg.year is null then 'Unknown'
		else dg.year :: text
	end as year_label,
	dg.year_key,
	dg.rank,
	f.na_sales,
	f.eu_sales,
	f.jp_sales,
	f.other_sales,
	f.global_sales
from dw.fact_sales f
join dw.dim_game dg
	on dg.game_id = f.game_id
left join dw.dim_platform p
	on p.platform_id = dg.platform_id
left join dw.dim_genre g
	on g.genre_id = dg.genre_id
left join dw.dim_publisher pub
	on pub.publisher_id = dg.publisher_id;	
/*

-- Validating...

select * from dw.vw_sales_enriched;qqqq

select count(*) as vw_lines, (select count(*) from dw.fact_sales) as fact_lines from dw.vw_sales_enriched;

*/
	