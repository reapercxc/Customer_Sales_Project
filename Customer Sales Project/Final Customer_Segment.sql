With Main as (SELECT
  customer_transaction_id,
  customer_id,
  transaction_date,
  amount_excluding_tax,
  cast(transaction_amount as decimal) as transaction_amount_fixed,
  is_finalized
FROM `vit-lam-data.wide_world_importers.sales__customer_transactions`
Order by customer_id)

, RFM_table as (select
  customer_id,
  date_diff(Current_timestamp(), Max(Transaction_date), day) as Recency,
  countif(transaction_amount_fixed > 0) as Frequency, --k count distinct cx đc vì đây là khóa chính
  sum(transaction_amount_fixed) as Monetary
from Main
group by customer_id
order by customer_id)

,RFM_table_percentile as (select
  *,
  percent_rank() over (order by frequency) as frequency_percentile,
  percent_rank() over (order by monetary) as monetary_percentile
from RFM_table)

, RFM_rank as (select
  *,
  case
  when recency between 2400 and 2520 then 3
  when recency between 2521 and 2530 then 2
  when recency between 2531 and 2600 then 1
  else 0
  end as recency_rank,
  case
  when frequency_percentile between 0.8 and 1 then 3
  when frequency_percentile between 0.5 and 0.8 then 2
  when frequency_percentile between 0 and 0.5 then 1
  else 0
  end as frequency_rank,
  case
  when monetary_percentile between 0.8 and 1 then 3
  when monetary_percentile between 0.5 and 0.8 then 2
  when monetary_percentile between 0 and 0.5 then 1
  else 0
  end as monetary_rank,
from RFM_table_percentile)

,RFM_rank_index as (select
  *,
  concat(recency_rank, frequency_rank,monetary_rank) as index
from RFM_rank)

select
  *,
  case
  when index in ('333','323','332','233','223') then 'VIP'
  when index in ('322','133','331','313','222','232') then 'Focus'
  else 'Normal'
  end as Customer_Segment
from RFM_rank_index
