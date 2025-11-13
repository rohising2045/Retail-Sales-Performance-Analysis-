use retail_analytics;
create table sales (
    sale_id int auto_increment primary key,
    date date,
    transaction_id int,
    store_id int,
    product_category varchar(100),
    units_sold int,
    unit_price decimal(10,2),
    cost_per_unit decimal(10,2),
	foreign key (store_id) references stores(store_id)
);
create table stores (
    store_id int primary key,
    store_name varchar(100),
    city varchar(100),
    region varchar(100),
    store_size int,
    open_date date
);

select * from stores; 
select * from sales;

select * from sales s
left join stores st
on s.store_id = st.store_id;

-- counting the stores 
select count(distinct store_id)as Total_stores from stores;

-- finding the biggest store area wise
SELECT city, store_size
FROM stores
ORDER BY store_size DESC
LIMIT 1;

-- Total Product category
select count(distinct product_category)as product_categories from sales;

-- Total Revenue
select sum(units_sold * unit_price)as Total_revenue from sales;

-- Total cost
select sum(units_sold * cost_per_unit)as Total_cost from sales;

-- Total Profit
select sum(units_sold *(unit_price - cost_per_unit))as Total_profit from sales;

-- Store-wise Sales Performance
select 
sales.store_id,
stores.store_name,
stores.region,
sum(sales.units_sold * sales.unit_price) as revenue,
sum(sales.units_sold * (sales.unit_price - sales.cost_per_unit)) as profit
from sales join stores 
on sales.store_id = stores.store_id
group by sales.store_id, stores.store_name, stores.region
order by profit desc;
-- can use limit 1 for the highest performing store

-- Region-wise Revenue & Profit
select 
stores.region,
sum(sales.units_sold * sales.unit_price) as Revenue,
sum(sales.units_sold * (sales.unit_price - sales.cost_per_unit)) as Profit
from sales join stores
on sales.store_id = stores.store_id
group by stores.region
order by Profit desc;

-- Monthly Sales Trend
select
date_format(date, '%Y-%m') as month,
SUM(units_sold * unit_price) as monthly_revenue,
SUM(units_sold * (unit_price - cost_per_unit)) as monthly_profit
from sales
group by DATE_FORMAT(date, '%Y-%m')
order by month;

-- Product Category Performance
select 
product_category,
sum(units_sold * unit_price)as Revenue,
sum(units_sold * (unit_price - cost_per_unit)) as Profit
from sales
group by product_category 
order by Profit desc;

-- Most Profitable Store
select 
stores.store_name,
stores.city,
sum(sales.units_sold * (sales.unit_price - sales.cost_per_unit)) as profit 
from sales join stores on
sales.store_id = stores.store_id
group by stores.store_name, stores.city
order by profit desc 
limit 1;

-- City-wise Revenue Distribution.
select 
stores.city,
sum(sales.units_sold * sales.unit_price) as Revenue,
sum(sales.units_sold * (sales.unit_price - sales.cost_per_unit)) as Profit
from sales join stores
on sales.store_id = stores.store_id
group by stores.city
order by Profit desc;

-- Profit Margin by Category
select 
product_category,
round((SUM(units_sold * (unit_price - cost_per_unit)) / SUM(units_sold * unit_price)) * 100, 2) as profit_margin_percent
from sales
group by product_category
order by profit_margin_percent desc;

-- Yearly Growth Trend(by profit percentage)
select
year(date) as Year,
round((sum(units_sold * (unit_price - cost_per_unit)) / sum(units_sold * unit_price)) * 100,2) as Profit_percentage
from sales
group by year(date)
order by profit_percentage;

-- Yearly Growth Trend(by Revenue values)
select 
year(date) as year,
(SUM(units_sold * unit_price),2) as total_revenue
from sales
group by year(date)
order by year;

-- Top 10 Transactions by Revenue
select 
transaction_id,
date,
(units_sold * unit_price) AS revenue
FROM sales
ORDER BY revenue DESC
LIMIT 10;

-- Store Size vs Performance
SELECT 
stores.store_size,
SUM(sales.units_sold * sales.unit_price) AS total_revenue
FROM sales 
JOIN stores ON sales.store_id = stores.store_id
GROUP BY stores.store_size
ORDER BY stores.store_size DESC;

-- Average Selling Price by Category
SELECT 
product_category,
ROUND(AVG(unit_price),2) AS avg_price
FROM sales
GROUP BY product_category
ORDER BY avg_price DESC;

-- Find Stores Opened in Last 2 Years
SELECT store_name, city, open_date
FROM stores
WHERE open_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

-- Region with Highest Number of Store.
SELECT region, COUNT(store_id) AS total_stores
FROM stores
GROUP BY region
ORDER BY total_stores DESC;




-- 01: view to check revenue city wise

create view city_revenue_view as
select 
stores.city,
round(sum(sales.units_sold * sales.unit_price), 2) as total_revenue
from sales 
join stores  
on sales.store_id = stores.store_id
group by stores.city
order by total_revenue desc;

-- checking the view
select * from city_revenue_view;

-- 01: view to check revenue store wise wise

create view store_revenue_view as
select 
sales.store_id,
stores.store_name,
stores.region,
sum(sales.units_sold * sales.unit_price) as revenue,
sum(sales.units_sold * (sales.unit_price - sales.cost_per_unit)) as profit
from sales join stores 
on sales.store_id = stores.store_id
group by sales.store_id, stores.store_name, stores.region
order by profit desc;

-- checking the view
select * from store_revenue_view;

--   Creating the Stored Procedure 

-- City-wise Revenue Procedure

DELIMITER //

create procedure get_city_revenue(in p_city varchar(100))
begin
    select 
	stores.city,
	ROUND(SUM(sales.units_sold * sales.unit_price), 2) as total_revenue,
	ROUND(SUM(sales.units_sold * (sales.unit_price - sales.cost_per_unit)), 2) as total_profit
    from sales 
    join stores on sales.store_id = stores.store_id
    where stores.city = p_city
    group by stores.city
    order by total_revenue desc;
end //

DELIMITER ;

-- checkin the procedure for city wise revenue
call get_city_revenue('Mumbai');

-- Month-wise Trend Procedure

delimiter //

create procedure getmonthlytrend()
begin
    select 
	date_format(date, '%Y-%m') as month,
	round(sum(units_sold * unit_price), 2) as total_revenue,
	round(sum(units_sold * (unit_price - cost_per_unit)), 2) as total_profit
    from sales
    group by date_format(date, '%Y-%m')
    order by month;
end //

delimiter ;

-- checking month wise trend 
call getmonthlytrend();


-- making Function to fetch insights from data

-- function to get total revenue

delimiter //

create function gettotalrevenue()
returns decimal(15,2)
deterministic
begin
    declare total_revenue decimal(15,2);
    select sum(units_sold * unit_price)
    into total_revenue
    from sales;
    return total_revenue;
end //

delimiter ;

-- call function to get total revenue
select gettotalrevenue();

-- function for Profit Margin Percentage 

delimiter //

create function getprofitmargin()
returns decimal(5,2)
deterministic
begin
    declare total_revenue decimal(15,2);
    declare total_profit decimal(15,2);
    declare profit_margin decimal(5,2);
    select sum(units_sold * unit_price),sum(units_sold * (unit_price - cost_per_unit))
    into total_revenue, total_profit from sales;
    set profit_margin = (total_profit / total_revenue) * 100;
    return profit_margin;
end //

delimiter ;

-- call function to get the profit margin percentage
select getprofitmargin() as Profit_Margin_Percentage;


-- function for average sale per store

delimiter //

create function getavgstoresale()
returns decimal(15,2)
deterministic
begin
    declare avg_sale decimal(15,2);
    select avg(total_sales)
    into avg_sale
    from (select sum(units_sold * unit_price) as total_sales from sales
	group by store_id) as store_sales;
    return avg_sale;
end //

delimiter ;

-- call function to get average sale per store
select getavgstoresale()as Average_Sales_Per_Store;







