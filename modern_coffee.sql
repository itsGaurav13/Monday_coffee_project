-- Monday Coffee Database
select*from city;
select*From customers;
select*From product;
select*From sales;

-- Reports & Data Analysis


-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select city_name, 
round((population*.25)/1000000,2 )as consume_coffe_in_millions ,
city_rank 
from city
order by 2 desc;

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select *From sales;

SELECT ci.city_name, sum(s.total) as Total_Revenue
FROM
    sales as s
    join customers as c
    on c.customer_id=s.customer_id
    join city as ci
    on ci.city_id=c.city_id
WHERE
    YEAR(s.sale_date) = 2023
        AND QUARTER(s.sale_date) = 4
        group by 1
        order by Total_Revenue desc;
        
        -- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

select*From product;
select*From sales;

SELECT 
    pro.Product_name as ProductName ,count(s.total)as count_order
FROM
    product as pro
    left join sales as s
    on s.product_id=pro.Product_id
    group by 1
    order by 2 desc;
    
    -- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city

select*from city;
select*From customers;
select*From product;
select*From sales;

SELECT 
    ci.city_name, SUM(s.total) AS total_revenue,
    COUNT(distinct c.customer_id)as Percustomer,
  round(SUM(s.total) /COUNT(distinct c.customer_id),2) as avg_sale_pr_cx
  
FROM
    sales s
        LEFT JOIN
    customers c ON c.customer_id = s.customer_id
        LEFT JOIN
    city ci ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC
;

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

with city_table as
(
select city_name,
round((population*0.25)/1000000,2) as population
from city
),
customers_table as
(
select
ci.city_name,
count( distinct c.customer_id) as estimated_coffee_consumers
From sales as s
join customers as c
on c.customer_id=s.customer_id
join city as ci
on ci.city_id=c.city_id
group by 1 )
select 
city_table.city_name,
city_table.population,
estimated_coffee_consumers 

from city_table
join customers_table as cust
on city_table.city_name=cust.city_name
order by 2 desc;


-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?


select*from
(SELECT  
    ci.city_name,
    pro.Product_name,
    count(s.sale_id) as total_sales,
    dense_rank() over(partition by ci.city_name order by count(s.sale_id)desc) as pro_rank_of_each_city
    
FROM
    sales AS s
    left join product as pro
    on pro.Product_id=s.product_id
    left join customers as c
    on c.customer_id=s.customer_id
    left join city as ci
    on ci.city_id=c.city_id
group by 1,2) as t1
where pro_rank_of_each_city <= 3;

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?



SELECT 
    
    ci.city_name,
    count(distinct c.customer_id) as  unique_customer
FROM
    customers AS c
        LEFT JOIN
    city AS ci ON ci.city_id = c.city_id
        LEFT JOIN
    sales AS s ON s.customer_id = c.customer_id
        JOIN
    product AS pro ON pro.Product_id = s.product_id
    where 
    s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
    group by 1;

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with city_sales as
(
select
ci.city_name,
sum(s.total) as total_revenue,
count( distinct c.customer_id) as total_cx,
round(sum(s.total)/count( distinct c.customer_id),2) as avg_sale_pr_customer
from sales as s 
left join customers as c
on c.customer_id=s.customer_id
left join city as ci
on ci.city_id=c.city_id
group by 1),
city_rent
as
(
select 
city_name,
estimated_rent
from city
)
select
cr.city_name,
cr.estimated_rent,
cs.total_cx,
round(cr.estimated_rent/cs.total_cx,2),
avg_sale_pr_customer
from city_rent as cr
join city_sales as cs
on cs.city_name=cr.city_name
order by 4,5;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
select*from city;
select*From customers;
select*From product;

with monthly_sales as
(
select 
ci.city_name,
extract( month from s.sale_date) as month,
extract(year from s.sale_date) as year,
sum(s.total) as total_sale
from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id=c.city_id
group by 1,2,3
order by 1,3,2
),
growth_ration
as
(
select
city_name,
month,
year,
total_sale as current_sales,
lag(total_sale,1) over(partition by city_name order by  year,month) as last_month_sale
from monthly_sales
)

select city_name,
month,
year,
current_sales from monthly_sales;
