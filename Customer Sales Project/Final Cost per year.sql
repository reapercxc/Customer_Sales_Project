with Main as (SELECT 
  supplier_transaction_id,
  transaction_date,
  cast(transaction_amount as decimal) as transaction_amount_fixed,
  is_finalized
FROM `vit-lam-data.wide_world_importers.purchasing__supplier_transactions`
where transaction_amount > 0
order by transaction_date)

,Cost_table as (select
  date_trunc(transaction_date, year) as Cost_per_year,
  sum(Main.transaction_amount_fixed) as Cost,
From main
group by Cost_per_year
order by Cost_per_year)

select
  extract(year from cost_per_year) as Year_number,
  case
    when cost > 100000000 then cost/10
    else cost
  end as Cost_fixed
from cost_table