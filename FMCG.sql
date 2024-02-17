/* 1 */
select  distinct product_name, e.product_code, base_price, promo_type from fact_events e
join dim_products p
on e.product_code = p.product_code
where base_price > 500
and promo_type like "%BOGOF%";

/*2*/
select city, count(distinct store_id) as store_count from dim_stores
group by city
order by store_count desc;


/*3*/
SELECT campaign_name, round(sum(base_price*quantity_sold_before_promo)/1000000,2) as revenue_pre_promo,
round(sum(base_price*quantity_sold_after_promo)/1000000,2) as revenue_post_promo
FROM fact_events e
join dim_campaigns c
on e.campaign_id = c.campaign_id
group by campaign_name;


/*4*/
with cte1 as(select category, 
round(sum(quantity_sold_after_promo-quantity_sold_before_promo)*100/(sum(quantity_sold_before_promo)),2) as ISU_pct
from fact_events e
join dim_products p
on e.product_code = p.product_code
where campaign_id like "%CAMP_DIW_01%"
group by category),
cte2 as(select *, rank() over(order by ISU_pct desc) as rank_order from cte1)
select * from cte2;

/*5*/
with cte1 as (SELECT distinct product_name, category, campaign_name,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as revenue_pre_promo,
round(sum(base_price*quantity_sold_after_promo)/1000000,2) as revenue_post_promo
FROM fact_events e
join dim_products p
on e.product_code = p.product_code
join dim_campaigns c
on e.campaign_id = c.campaign_id
group by product_name, category, campaign_name),
cte2 as (select *,
round(sum(revenue_post_promo-revenue_pre_promo)*100/(revenue_pre_promo),2) as IR_pct from cte1
group by product_name, category, campaign_name),
cte3 as (select *, dense_rank() over(partition by campaign_name order by IR_pct desc) as drnk from cte2)
select * from cte3
where drnk <=5;






