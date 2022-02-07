use [E-commerce]
-- I'll do some exploratory analysis on the dataset

--First I'd like to see the distribution of sales (money-wise) across the cities of Brazil

select c.["customer_city"] as City, sum(p.["payment_value"]) as total_amount
from olist_customers_dataset c
left join olist_orders_dataset o
on c.["customer_id"] = o.["customer_id"]
left join olist_order_payments_dataset p
on p.["order_id"] = o.["order_id"]
group by c.["customer_city"]
order by 2 desc
go
-- Now I want to give a Pareto classification to each city (A = up to 80% of sales, B = up to 15% o sales, and C = 5% of sales)
select *, sum(proportion_of_sales) over(order by total_amount desc) as cumulative_proportion,
case when sum(proportion_of_sales) over(order by total_amount desc) < 0.8 then 'A'
	when sum(proportion_of_sales) over(order by total_amount desc) >=0.8 and sum(proportion_of_sales) over(order by total_amount desc)<0.95 then 'B'
	else 'C' end as pareto_classification
from
(
select *, sum(total_amount) over() as total_sales, total_amount/sum(total_amount) over() as proportion_of_sales
from
(
select c.["customer_city"] as City, sum(p.["payment_value"]) as total_amount
from olist_customers_dataset c
join olist_orders_dataset o
on c.["customer_id"] = o.["customer_id"]
join olist_order_payments_dataset p
on p.["order_id"] = o.["order_id"]
group by c.["customer_city"]
order by total_amount desc offset 0 rows
)as sub
order by sub.total_amount desc offset 0 rows
) as a
go
-- Now I want to know how many cities fall under each pareto classification
with cte as
(
select *, sum(proportion_of_sales) over(order by total_amount desc) as cumulative_proportion,
case when sum(proportion_of_sales) over(order by total_amount desc) < 0.8 then 'A'
	when sum(proportion_of_sales) over(order by total_amount desc) >=0.8 and sum(proportion_of_sales) over(order by total_amount desc)<0.95 then 'B'
	else 'C' end as pareto_classification
from
(
select *, sum(total_amount) over() as total_sales, total_amount/sum(total_amount) over() as proportion_of_sales
from
(
select c.["customer_city"] as City, sum(p.["payment_value"]) as total_amount
from olist_customers_dataset c
left join olist_orders_dataset o
on c.["customer_id"] = o.["customer_id"]
left join olist_order_payments_dataset p
on p.["order_id"] = o.["order_id"]
group by c.["customer_city"]
order by total_amount desc offset 0 rows
)as sub
order by sub.total_amount desc offset 0 rows
) as a
)
select pareto_classification, count(pareto_classification) as qty_of_cities
from cte
group by pareto_classification
go

-- Now I'd like to see which are the top 10 product categories sold in terms of money and in how many orders did each category appeared

select top (10) t.product_category_name_english, sum(pay.["payment_value"]) as sales_value, count(o.["order_id"]) as amount_of_orders
from product_category_name_translation t
left join olist_products_dataset p
on t.product_category_name = p.["product_category_name"]
left join olist_order_items_dataset o
on p.["product_id"] = o.["product_id"]
left join olist_order_payments_dataset pay
on o.["order_id"] = pay.["order_id"]
group by t.product_category_name_english
order by 2 desc
go
-- Now I'd like to know the top 10 products sold (based on money amount) that weighted more than 10 kgs

select top 10 p.["product_id"], sum(i.["price"]) as money_amount_sold
from olist_products_dataset p
left join olist_order_items_dataset i
on p.["product_id"] = i.["product_id"]
where p.["product_weight_g"] > 10000
group by p.["product_id"]
order by 2 desc
go
-- Now I want to identify the sellers, its states, amount of clients the sellers sold, the total amount sold per seller 
-- and the total amount per state, order from the biggest amount to the smallest
with cte as
(
select s.["seller_id"], s.["seller_state"] as seller_state, count(o.["customer_id"]) total_clients ,sum(i.["price"]) as total_amount
from olist_sellers_dataset s
left join olist_order_items_dataset i
on s.["seller_id"] = i.["seller_id"]
left join olist_orders_dataset o
on i.["order_id"] = o.["order_id"]
group by s.["seller_id"], s.["seller_state"]
order by 4 desc offset 0 rows
)
select *, sum(total_amount) over(partition by seller_state) as cumulative_state_total_amount
from cte
order by 5 desc
go

--Now I want to display a table with the total amount of sales per customer city
--but only including those sales that were fully paid in 1 installment

select c.["customer_city"], sum(p.["payment_value"]) as total_amount_sales
from olist_customers_dataset c
left join olist_orders_dataset o
on c.["customer_id"] = o.["customer_id"]
left join olist_order_payments_dataset p
on o.["order_id"] = p.["order_id"]
left join olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
where p.["payment_installments"] = 1
group by c.["customer_city"]
order by 2 desc
go

--Now I want a table that will display the order id, customer id, the date the order was placed, the amount of the order and the seller

select o.["order_id"], ["customer_id"], cast(o.["order_purchase_timestamp"] as date) as purchase_date,
sum(i.["price"]) as total_amount, s.["seller_id"]
from olist_orders_dataset o
join olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
join olist_sellers_dataset s
on i.["seller_id"] = s.["seller_id"]
group by o.["order_id"], ["customer_id"],cast(o.["order_purchase_timestamp"] as date),s.["seller_id"]
go

-- Based on the previous table I want to know the evolution of of sales per year, both in amount of orders and money
select DATEPART(year,t.purchase_date) as years, count(t.["order_id"]) as total_orders, sum(t.total_amount) as total_amount
from
(select o.["order_id"], ["customer_id"], cast(o.["order_purchase_timestamp"] as date) as purchase_date,
sum(i.["price"]) as total_amount, s.["seller_id"]
from olist_orders_dataset o
join olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
join olist_sellers_dataset s
on i.["seller_id"] = s.["seller_id"]
group by o.["order_id"], ["customer_id"],cast(o.["order_purchase_timestamp"] as date),s.["seller_id"]
) as t
group by DATEPART(year,t.purchase_date)
order by 1
go

--Now I want to break this information out in months for the lattest year

select DATEPART(month,t.purchase_date) as years, count(t.["order_id"]) as total_orders, sum(t.total_amount) as total_amount
from
(select o.["order_id"], ["customer_id"], cast(o.["order_purchase_timestamp"] as date) as purchase_date,
sum(i.["price"]) as total_amount, s.["seller_id"]
from olist_orders_dataset o
join olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
join olist_sellers_dataset s
on i.["seller_id"] = s.["seller_id"]
group by o.["order_id"], ["customer_id"],cast(o.["order_purchase_timestamp"] as date),s.["seller_id"]
) as t
where DATEPART(year,t.purchase_date) = 2018
group by DATEPART(month,t.purchase_date)
order by 1
go

-- I want to identify the sales done by payment method, the total amount of sales and the total amount of customers that used for each

select p.["payment_type"], count(o.["customer_id"]) as total_customers, sum(i.["price"]) as total_sales
from olist_order_payments_dataset p
left join olist_orders_dataset o
on p.["order_id"] = o.["order_id"]
left join olist_order_items_dataset i
on p.["order_id"] = i.["order_id"]
group by p.["payment_type"]
having count(o.["customer_id"]) is not null and sum(i.["price"]) is not null
order by 3 desc

--Now that I know most of the clients use credit cards, I want to locate those customers' cities, sales and number of orders
select o.["customer_id"], c.["customer_city"], sum(i.["price"]) as total_sales, count(o.["order_id"]) as total_orders
from olist_order_payments_dataset p
left join olist_orders_dataset o
on p.["order_id"] = o.["order_id"]
left join olist_order_items_dataset i
on p.["order_id"] = i.["order_id"]
left join olist_customers_dataset c
on o.["customer_id"] = c.["customer_id"]
where p.["payment_type"] = 'credit_card'
group by  o.["customer_id"], c.["customer_city"]
order by 3 desc