With Main as (SELECT
  customer_transaction_id,
  customer_id,
  transaction_date,
  transaction_amount,
  is_finalized
FROM `vit-lam-data.wide_world_importers.sales__customer_transactions`
where transaction_amount > 0 and transaction_date >= '2015-01-01'
Order by customer_id)

,first_transaction as (select
  customer_id,
  date_trunc(min(transaction_date),month) as first_month
from Main
group by customer_id
order by customer_id)

,new_customers_by_month as (select
  first_month,
  count(customer_id) as new_customers
from first_transaction
group by first_month
order by first_month)

,customers_retention_month as (select
  customer_id,
  date_trunc(transaction_date,month) as retention_month
from main
group by customer_id, retention_month
order by 1,2)

,retained_customers as (select
  first_transaction.first_month,
  customers_retention_month.retention_month,
  count(first_transaction.customer_id) as retention_customers
from customers_retention_month join first_transaction
on first_transaction.customer_id = customers_retention_month.customer_id
group by 
  customers_retention_month.retention_month, 
  first_transaction.first_month
order by 1,2)

select
  retained_customers.first_month,
  retained_customers.retention_month,
  date_diff(date(retained_customers.retention_month), date(retained_customers.first_month),month) as retention_month_no,
  new_customers_by_month.new_customers,
  retained_customers.retention_customers,
  (retained_customers.retention_customers / new_customers_by_month.new_customers)*100 as retention_rate
from retained_customers join new_customers_by_month
on retained_customers.first_month = new_customers_by_month.first_month
order by 1,2