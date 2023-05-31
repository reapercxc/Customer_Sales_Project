with compare_negative_transaction as (select
 b1.customer_id,
 b2.customer_id,
 b1.transaction_amount,
 b2.transaction_amount,
 b1.transaction_date,
 b2.transaction_date
from  `vit-lam-data.wide_world_importers.sales__customer_transactions` as b1 join `vit-lam-data.wide_world_importers.sales__customer_transactions` as b2
on b1.customer_id = b2.customer_id and b1.transaction_amount = 0 - b2.transaction_amount
where b1.customer_id = 979
order by b1.transaction_amount desc)

, negative_transaction_count as (select
  customer_id as cs2,
  sum(transaction_amount) as ta2
from `vit-lam-data.wide_world_importers.sales__customer_transactions`
where transaction_amount < 0
group by cs2
order by customer_id)

, positive_transaction_count as (select
  customer_id as cs1,
  sum(transaction_amount) as ta1
from `vit-lam-data.wide_world_importers.sales__customer_transactions`
where transaction_amount > 0
group by cs1
order by customer_id)

select 
  *,
  ta1 + ta2 as ta1_plus_ta2
from positive_transaction_count as p, negative_transaction_count as n
where cs1 = cs2
and ta1 < - ta2
order by cs1