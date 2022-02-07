use [E-commerce]
-- First I'm going to change the data types of some columns on all the tables because when I imported them they were all set as varchars

-- Let's start with the customers_dataset

Select top(10) * From olist_customers_dataset
go
-- the original result for the "customer_zip_code_prefix" column displays the numbers as varchars between quotation marks
--I'll change them to integers
select cast(replace(["customer_zip_code_prefix"],'"','') as int)
from olist_customers_dataset

update olist_customers_dataset
set ["customer_zip_code_prefix"] = cast(replace(["customer_zip_code_prefix"],'"','') as int)

alter table olist_customers_dataset
alter column ["customer_zip_code_prefix"] int

Select top(10) * From olist_customers_dataset
go
--both the customer_id and customer_unique_id have quotation marks in some rows. For consistency I will remove the quotation marks
update olist_customers_dataset
set ["customer_id"] = (case	when ["customer_id"] like '"%' then replace(["customer_id"],'"','')	else ["customer_id"] end)
go

update olist_customers_dataset
set ["customer_unique_id"] = (case when ["customer_unique_id"] like '"%' then replace(["customer_unique_id"],'"','') else ["customer_unique_id"] end)
go
--checking if the changes took place
select ["customer_id"], ["customer_unique_id"]
from olist_customers_dataset
where ["customer_id"] like '"%' or ["customer_unique_id"] like '"%'
go
--now I'll change the lenght of the rest of the varchar columns
select max(len(["customer_id"])) as customer_id_len, max(len(["customer_unique_id"])) as customer_unique_len,
max(len(["customer_city"])) as customer_city_len, max(len(["customer_state"])) as customer_state_len
from olist_customers_dataset
go

alter table olist_customers_dataset
alter column ["customer_id"] varchar(32)
go

alter table olist_customers_dataset
alter column ["customer_unique_id"] varchar(32)
go

alter table olist_customers_dataset
alter column ["customer_city"] varchar(32)
go

alter table olist_customers_dataset
alter column ["customer_state"] varchar(2)
go

-- Moving on to the geolocation dataset

select top (10) * from olist_geolocation_dataset
go
--changing the geolocation_zip_code_prefix to integers
select cast(replace("""geolocation_zip_code_prefix""",'"','') as int)
from olist_geolocation_dataset
go

update olist_geolocation_dataset
set ["geolocation_zip_code_prefix"] = cast(replace("""geolocation_zip_code_prefix""",'"','') as int)
go

alter table olist_geolocation_dataset
alter column ["geolocation_zip_code_prefix"] int
go
--changing the lat and lng columns to decimals
alter table olist_geolocation_dataset
alter column ["geolocation_lat"] decimal(10,7)
go

alter table olist_geolocation_dataset
alter column ["geolocation_lng"] decimal(10,7)
go
--changing the lenght of the varchar columns
select max(len(["geolocation_city"])) as geolocation_city_lenght, max(len(["geolocation_state"])) as geolocation_state_lenght
from olist_geolocation_dataset
go

alter table olist_geolocation_dataset
alter column ["geolocation_city"] varchar(36)
go

alter table olist_geolocation_dataset
alter column ["geolocation_state"] varchar(27)
go

-- Moving on to the order items dataset

select top(10) * from olist_order_items_dataset
go
-- removing the quotation marks and changing the length of the order_id column
update olist_order_items_dataset
set ["order_id"] = (case when ["order_id"] like '"%' then replace(["order_id"],'"','') else ["order_id"] end)
go

select max(len(["order_id"]))
from olist_order_items_dataset

alter table olist_order_items_dataset
alter column ["order_id"] varchar(32)
go
--working on the order_item_id
select distinct ["order_item_id"]
from olist_order_items_dataset
go
-- since the values for this work as an ID, I will leave them as varchar, but alter the lenght
alter table olist_order_items_dataset
alter column ["order_item_id"] varchar(2)
go
-- working on the product and seller id columns
update olist_order_items_dataset
set ["product_id"] = (case when ["product_id"] like '"%' then replace(["product_id"],'"','') else ["product_id"] end)
go
update olist_order_items_dataset
set ["seller_id"] = (case when ["seller_id"] like '"%' then replace(["seller_id"],'"','') else ["seller_id"] end)
go

select max(len(["product_id"])), max(len(["seller_id"]))
from olist_order_items_dataset
go

alter table olist_order_items_dataset
alter column ["product_id"] varchar(32)
go

alter table olist_order_items_dataset
alter column ["seller_id"] varchar(32)
go
--working on the shipping_limit_date column
alter table olist_order_items_dataset
alter column ["shipping_limit_date"] smalldatetime
-- working on the price and freight_value columns
-- first I will check the number of decimals both columns should have and then I'll convert them to decimals
select max(len(parsename(["price"],1))) as price_decimals, max(len(parsename(["freight_value"],1))) as freight_decimals
from olist_order_items_dataset

select max(len(parsename(["price"],2))) as price_int, max(len(parsename(["freight_value"],2))) as freight_int
from olist_order_items_dataset
go
-- Now I know that for price the integer part is 4 digits long and for freight_value is 3. Both have 2 digits for decimals
alter table olist_order_items_dataset
alter column ["price"] decimal(6,2)
go

alter table olist_order_items_dataset
alter column ["freight_value"] decimal(5,2)
go

-- Moving on to the payments dataset

select top (10) *
from olist_order_payments_dataset
go
--working on the order_id column
update olist_order_payments_dataset
set ["order_id"] = (case when ["order_id"] like '"%' then replace(["order_id"],'"','') else ["order_id"] end)
go
select max(len(["order_id"]))
from olist_order_payments_dataset
go
alter table olist_order_payments_dataset
alter column ["order_id"] varchar(32)
go
--working on the payment_sequential column
select distinct ["payment_sequential"]
from olist_order_payments_dataset
go
--since it's all numbers I'll just covert the column values to tinyints
alter table olist_order_payments_dataset
alter column ["payment_sequential"] tinyint
go
--working on the payment_type column
select max(len(["payment_type"]))
from olist_order_payments_dataset
go
alter table olist_order_payments_dataset
alter column ["payment_type"] varchar(11)
go
--working on the payment_installments column
alter table olist_order_payments_dataset
alter column ["payment_installments"] tinyint
go
--working on the payment_value column
select max(len(parsename(["payment_value"],2))) as int_digits, max(len(parsename(["payment_value"],1))) as decimal_digits
from olist_order_payments_dataset
go
alter table olist_order_payments_dataset
alter column ["payment_value"] decimal(7,2)
go

-- Moving on to the order reviews dataset

select top(10) *
from olist_order_reviews_dataset
go
--working on the review_id
select review_id
from olist_order_reviews_dataset
where order_id like '"%'
go
select max(len(review_id))
from olist_order_reviews_dataset
go
alter table olist_order_reviews_dataset
alter column review_id varchar(32)
go
--working on the order_id column
select order_id
from olist_order_reviews_dataset
where order_id like '"%'
go
select max(len(order_id))
from olist_order_reviews_dataset
go
alter table olist_order_reviews_dataset
alter column order_id varchar(32)
go
--working on the order_id column
select distinct review_score
from olist_order_reviews_dataset
go
alter table olist_order_reviews_dataset
alter column review_score tinyint
go
-- working on the review_comment_title column
select max(len(review_comment_title))
from olist_order_reviews_dataset
go
alter table olist_order_reviews_dataset
alter column review_comment_title varchar(35)
go
-- working on the review_comment_message column
select max(len(review_comment_message))
from olist_order_reviews_dataset
go
alter table olist_order_reviews_dataset
alter column review_comment_message varchar(269)
go
--working on the review_creation_date
alter table olist_order_reviews_dataset
alter column review_creation_date smalldatetime
go
--working on the review_answer_timestamp column
alter table olist_order_reviews_dataset
alter column review_answer_timestamp smalldatetime
go

-- Moving on to the orders dataset

select top(10) * from olist_orders_dataset
go
--working with the order and customer_id columns
update  olist_orders_dataset
set ["order_id"] = (case when ["order_id"] like '"%' then REPLACE(["order_id"],'"','') else ["order_id"] end)
go
update  olist_orders_dataset
set ["customer_id"] = (case when ["customer_id"] like '"%' then REPLACE(["customer_id"],'"','') else ["customer_id"] end)
go
select max(len(["order_id"])) as order_id,max(len(["customer_id"])) as customer_id
from olist_orders_dataset
go
alter table olist_orders_dataset
alter column ["order_id"] varchar(32)
go
alter table olist_orders_dataset
alter column ["customer_id"] varchar(32)
go
--working on the order_status column
select max(len(["order_status"]))
from olist_orders_dataset
go
alter table olist_orders_dataset
alter column ["order_status"] varchar(11)
go
--working with the resto of the columns to set them as smalldatetime variables
alter table olist_orders_dataset
alter column ["order_purchase_timestamp"] smalldatetime
go
alter table olist_orders_dataset
alter column ["order_approved_at"] smalldatetime
go
alter table olist_orders_dataset
alter column ["order_delivered_carrier_date"] smalldatetime
go
alter table olist_orders_dataset
alter column ["order_delivered_customer_date"] smalldatetime
go
alter table olist_orders_dataset
alter column ["order_estimated_delivery_date"] smalldatetime
go

-- Moving on to the products dataset

select top(10) * from olist_products_dataset
go
--working on the product_id column
update  olist_products_dataset
set ["product_id"] = (case when ["product_id"] like '"%' then REPLACE(["product_id"],'"','') else ["product_id"] end)
go
select max(len(["product_id"]))
from olist_products_dataset
go
alter table olist_products_dataset
alter column ["product_id"] varchar(32)
go
--working on the product_category_name column
select max(len(["product_category_name"]))
from olist_products_dataset
go
alter table olist_products_dataset
alter column ["product_category_name"] varchar(46)
go
--working on the product_name_length column
select distinct["product_name_lenght"]
from olist_products_dataset
go
alter table olist_products_dataset
alter column ["product_name_lenght"] tinyint
go
--working on the product_description_length column
select ["product_description_lenght"], len(["product_description_lenght"]) as digits
from olist_products_dataset
where len(["product_description_lenght"]) > 2
order by digits desc
go
alter table olist_products_dataset
alter column ["product_description_lenght"] smallint
go
--working on the product_photos_qty
select ["product_photos_qty"], len(["product_photos_qty"]) as digits
from olist_products_dataset
where len(["product_photos_qty"]) > 2
order by digits desc
go
alter table olist_products_dataset
alter column ["product_photos_qty"] tinyint
--working on the product_weight_g column 
select ["product_weight_g"], len(["product_weight_g"]) as digits
from olist_products_dataset
where len(["product_weight_g"]) > 2 and ["product_weight_g"] like '4%'
order by digits desc
go
alter table olist_products_dataset
alter column ["product_weight_g"] int
go
--working on the product_length_cm column
select ["product_length_cm"], len(["product_length_cm"]) as digits
from olist_products_dataset
where len(["product_length_cm"]) > 2 --and ["product_length_cm"] like '3%'
order by digits desc
go
alter table olist_products_dataset
alter column ["product_length_cm"] tinyint
go
--working on the product_height_cm column
select ["product_height_cm"], len(["product_height_cm"]) as digits
from olist_products_dataset
where len(["product_height_cm"]) > 2 
order by digits desc
go
alter table olist_products_dataset
alter column ["product_height_cm"] tinyint
go
--working on the product_width_cm column
select ["product_width_cm"], len(["product_width_cm"]) as digits
from olist_products_dataset
where len(["product_width_cm"]) > 2 
order by digits desc
go
alter table olist_products_dataset
alter column ["product_width_cm"] tinyint
go

-- Moving on to the sellers_dataset

select top(10) * from olist_sellers_dataset
go
--working on the seller_id column
update olist_sellers_dataset
set ["seller_id"] = (case when ["seller_id"] like '"%' then REPLACE(["seller_id"],'"','') else ["seller_id"] end)
go
select max(len(["seller_id"]))
from olist_sellers_dataset
go
alter table olist_sellers_dataset
alter column ["seller_id"] varchar(32)
go
--working on the seller_zip_code_prefix column
update olist_sellers_dataset
set ["seller_zip_code_prefix"] = (case when ["seller_zip_code_prefix"] like '"%' then REPLACE(["seller_zip_code_prefix"],'"','') else ["seller_zip_code_prefix"] end)
go
select max(len(["seller_zip_code_prefix"]))
from olist_sellers_dataset
go
alter table olist_sellers_dataset
alter column ["seller_zip_code_prefix"] int
go
--working on the seller_city column
select max(len(["seller_city"]))
from olist_sellers_dataset
go
-- This query showed me that there is a city name with 31 characters, let's see which one it is
select ["seller_city"]
from olist_sellers_dataset
where len(["seller_city"]) = 31
go
--the city just says rio de janeiro twice, so I'll see other rows with rio like values
select ["seller_city"]
from olist_sellers_dataset
where ["seller_city"] like 'rio de%'
go
--looks like this value is a mistake, so I'll update that value on the column
update olist_sellers_dataset
set ["seller_city"] = (case when ["seller_city"] = 'rio de janeiro / rio de janeiro' then replace(["seller_city"],'rio de janeiro / rio de janeiro','rio de janeiro') else ["seller_city"] end)
go
select max(len(["seller_city"]))
from olist_sellers_dataset
go
--Now I see that a city is 30 characters long, let's check it out
select ["seller_city"]
from olist_sellers_dataset
where len(["seller_city"]) = 30
go
--the city says arraial d'ajuda (porto seguro), according to google, the city is porto seguro, so I'll adjust it to that value
update olist_sellers_dataset
set ["seller_city"] = (case when ["seller_city"] = 'arraial d''ajuda (porto seguro)' then replace(["seller_city"],'arraial d''ajuda (porto seguro)','porto seguro') else ["seller_city"] end)
go
select max(len(["seller_city"]))
from olist_sellers_dataset
go
--Now I have a value 26 characters long
select ["seller_city"]
from olist_sellers_dataset
where len(["seller_city"]) = 26
go
update olist_sellers_dataset
set ["seller_city"] = (case when ["seller_city"] = 'ribeirao preto / sao paulo' then replace(["seller_city"],'ribeirao preto / sao paulo','sao paulo') else ["seller_city"] end)
go
select max(len(["seller_city"]))
from olist_sellers_dataset
go
--Now I have a value 25 characters long
select ["seller_city"]
from olist_sellers_dataset
where len(["seller_city"]) = 25
go
--After taking a look at these values, they look legit so no more updating columns, just adjusting the maximum length for this column
alter table olist_sellers_dataset
alter column ["seller_city"] varchar(25)
go
--working on the seller_state column
select max(len(["seller_state"]))
from olist_sellers_dataset
go
--This query showed me that there is at least one row with more than 2 characters to describe the state, let's take a look
select ["seller_state"], len(["seller_state"])
from olist_sellers_dataset
where len(["seller_state"]) >2
go
--looks like the correct state codes for these 2 values would be RS and RJ, let's see if I already have rows with those values
select ["seller_state"]
from olist_sellers_dataset
where ["seller_state"] = 'RS' or ["seller_state"] = 'RJ'
go
--there are already 298 other rows with those 2 values, so I'll just update those two values in the column
update olist_sellers_dataset
set ["seller_state"] = (case when ["seller_state"] = ' rio grande do sul, brasil",RS' then replace(["seller_state"],' rio grande do sul, brasil",RS','RS') else ["seller_state"] end)
go
update olist_sellers_dataset
set ["seller_state"] = (case when ["seller_state"] = ' rio de janeiro, brasil",RJ' then replace(["seller_state"],' rio de janeiro, brasil",RJ','RJ') else ["seller_state"] end)
go
select max(len(["seller_state"]))
from olist_sellers_dataset
go
alter table olist_sellers_dataset
alter column ["seller_state"] varchar(2)
go

-- Moving on to the product category name translation dataset

select top(10) * from product_category_name_translation
--Since this table is so small there's no need to modify anything

-- While Working on the data I realized that I needed to do some changes with the geolocation dataset
-- The states had different latitudes and longitudes so I unified the values for each state as seen below
update olist_geolocation_dataset
set ["geolocation_lat"] = -9.070003236,
["geolocation_lng"] = -68.66997929
where ["geolocation_state"] = 'AC'

update olist_geolocation_dataset
set ["geolocation_lat"] = -9.48000405,
["geolocation_lng"] = -35.83996769
where ["geolocation_state"] = 'AL'

update olist_geolocation_dataset
set ["geolocation_lat"] = -0.039598369,
["geolocation_lng"] = -51.17998743
where ["geolocation_state"] = 'AP'

update olist_geolocation_dataset
set ["geolocation_lat"] = -3.289580873,
["geolocation_lng"] = -60.6199797
where ["geolocation_state"] = 'AM'

update olist_geolocation_dataset
set ["geolocation_lat"] = -16.28000242,
["geolocation_lng"] = -39.0299797
where ["geolocation_state"] = 'BA'

update olist_geolocation_dataset
set ["geolocation_lat"] = -2.89999225,
["geolocation_lng"] = -40.85002364
where ["geolocation_state"] = 'CE'

update olist_geolocation_dataset
set ["geolocation_lat"] = -15.78334023,
["geolocation_lng"] = -47.91605229
where ["geolocation_state"] = 'DF'

update olist_geolocation_dataset
set ["geolocation_lat"] = -20.85000771,
["geolocation_lng"] = -41.12998071
where ["geolocation_state"] = 'ES'

update olist_geolocation_dataset
set ["geolocation_lat"] = -17.73004311,
["geolocation_lng"] = -49.10998458
where ["geolocation_state"] = 'GO'

update olist_geolocation_dataset
set ["geolocation_lat"] = -5.809995505,
["geolocation_lng"] = -46.14998438
where ["geolocation_state"] = 'MA'

update olist_geolocation_dataset
set ["geolocation_lat"] = -15.65001504,
["geolocation_lng"] = -56.14002059
where ["geolocation_state"] = 'MT'

update olist_geolocation_dataset
set ["geolocation_lat"] = -22.53000853,
["geolocation_lng"] = -55.7299681
where ["geolocation_state"] = 'MS'

update olist_geolocation_dataset
set ["geolocation_lat"] = -18.78000486,
["geolocation_lng"] = -42.95002466
where ["geolocation_state"] = 'MG'

update olist_geolocation_dataset
set ["geolocation_lat"] = -1.190019105,
["geolocation_lng"] = -47.17999903
where ["geolocation_state"] = 'PA'

update olist_geolocation_dataset
set ["geolocation_lat"] = -7.019585756,
["geolocation_lng"] = -37.29000838
where ["geolocation_state"] = 'PB'

update olist_geolocation_dataset
set ["geolocation_lat"] = -24.08996499,
["geolocation_lng"] = -54.2699797
where ["geolocation_state"] = 'PR'

update olist_geolocation_dataset
set ["geolocation_lat"] = -8.110010153,
["geolocation_lng"] = -35.02004358
where ["geolocation_state"] = 'PE'

update olist_geolocation_dataset
set ["geolocation_lat"] = -4.820030091,
["geolocation_lng"] = -42.18001998
where ["geolocation_state"] = 'PI'

update olist_geolocation_dataset
set ["geolocation_lat"] = -22.56003253,
["geolocation_lng"] = -44.1699502
where ["geolocation_state"] = 'RJ'

update olist_geolocation_dataset
set ["geolocation_lat"] = -5.650005271,
["geolocation_lng"] = -37.80000309
where ["geolocation_state"] = 'RN'

update olist_geolocation_dataset
set ["geolocation_lat"] = -30.88004148,
["geolocation_lng"] = -55.53000615
where ["geolocation_state"] = 'RS'

update olist_geolocation_dataset
set ["geolocation_lat"] = -11.64002724,
["geolocation_lng"] = -61.20999536
where ["geolocation_state"] = 'RO'

update olist_geolocation_dataset
set ["geolocation_lat"] = 1.816231505,
["geolocation_lng"] = -61.12767481
where ["geolocation_state"] = 'RR'

update olist_geolocation_dataset
set ["geolocation_lat"] = -27.23003172,
["geolocation_lng"] = -52.03001306
where ["geolocation_state"] = 'SC'

update olist_geolocation_dataset
set ["geolocation_lat"] = -23.65283405,
["geolocation_lng"] = -46.52781661
where ["geolocation_state"] = 'SP'

update olist_geolocation_dataset
set ["geolocation_lat"] = -11.26961058,
["geolocation_lng"] = -37.45002446
where ["geolocation_state"] = 'SE'

update olist_geolocation_dataset
set ["geolocation_lat"] = -6.319576804,
["geolocation_lng"] = -47.41998438
where ["geolocation_state"] = 'TO'
go

-- Another change I'll do is with the reviwes dataset, I'll change the score from tiny int to varchar and intead of it just
-- displaying the number of stars I will add "star(s)" to the values

alter table olist_order_reviews_dataset
alter column review_score varchar(7)
go

update olist_order_reviews_dataset
set review_score = '1 star'
where review_score ='1'

update olist_order_reviews_dataset
set review_score = '2 stars'
where review_score ='2'

update olist_order_reviews_dataset
set review_score = '3 stars'
where review_score ='3'

update olist_order_reviews_dataset
set review_score = '4 stars'
where review_score ='4'

update olist_order_reviews_dataset
set review_score = '5 stars'
where review_score ='5'
go