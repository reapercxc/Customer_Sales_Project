with main as (SELECT
  customer_transaction_id,
  customer_id,
  transaction_date,
  cast(transaction_amount as decimal) as transaction_amount_fixed,
  is_finalized
FROM `vit-lam-data.wide_world_importers.sales__customer_transactions`
where transaction_amount > 0
Order by customer_id)

, revenue_table as (select
  date_trunc(transaction_date, year) as revenue_per_year,
  sum(Main.transaction_amount_fixed) as revenue
from Main
group by revenue_per_year
order by revenue_per_year)

select
  *,
  extract(year from revenue_per_year) as Year_number
from revenue_table