create database DAP;
use dap;

select * from customer limit 20;

# ---- Changing Column Name ----

Alter table customer
rename column `purchase_amount_(usd)` to purchase_amount;

#  ----- Total Revenue Male VS Female -----
select gender, sum(purchase_amount) as revenue
from customer
group by gender;

# ------ Customer who used discount but spent more than avg amount ------

select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount > (select avg(purchase_amount) from customer);

# ----- Top 5 products with the highest review rating -----

select item_purchased, round(avg(review_rating),2) as avg_rating
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

# ----- Avg purchase amount bw standrad and express shipping -------

select shipping_type, round(avg(purchase_amount),2) as avg_purchase_amount 
from customer
where shipping_type in ('Standard', 'Express')
group by shipping_type;

# ----- Compare avg spend and Total revenue bw subscribers and non-subscribers ------

select subscription_status, round(avg(purchase_amount),2) as avg_spend, sum(purchase_amount) as total_revenue
from customer
group by subscription_status;

# ----- Which 5 products have highest percentage of purchases with discount applied ------

select item_purchased,
round(sum(case when discount_applied = 'Yes'
then 1 else 0 end) * 100 / count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

# ----- Segment customers into New, Returning, Loyal based on their total number of previous purchases and show the count on each segment -----

select case
when previous_purchases = 1 then 'New'
when previous_purchases between 2 and 10 then 'Returning'
else 'Loyal' end
as customer_segment,
count(*) as customer_count
from customer
group by customer_segment;

# ----- Top 3 most purchased product with in each category ------

with item_counts as (
select category, item_purchased, count(customer_id) as total_orders,
row_number() over(
partition by category
order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

# ------ Are customer who are repeat buyers(more than 5) also likely to subscribe ------

select subscription_status, count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

# ------ Revenue by age group ------- 

select age_group, sum(purchase_amount) as revenue
from customer
group by age_group
order by revenue;