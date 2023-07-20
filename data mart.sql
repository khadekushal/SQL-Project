
select * from weekly_sales limit 10;
## Data Cleansing 

create table clean_weekly_sales as
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calender_year,
region,platform,
case 
when segment = 'null' then 'Unknown'
else segment
end as segment,
case 
when right(segment,1)='1' then 'Young Adult'
when right(segment,1)='2' then 'Middle Aged'
when right(segment,1) in ('3','4') then 'Retirees'
else 'unknown'
end as age_band,
case
when left(segment,1)='C' then 'Couples'
when left(segment,1)='F' then 'Family'
else 'Unknown'
end as demographic,
customer_type,transactions,sales,
round(sales/transactions,2) as 'avg_transaction'
from weekly_sales;

select * from clean_weekly_sales limit 10;

# Data Exploration

#1. Which week numbers are missing from the dataset?
drop table seq100;
create table seq100 (x int not null auto_increment primary key);
insert into seq100  values (),(),(),(),(),(),(),(),(),();
insert into seq100  values (),(),(),(),(),(),(),(),(),();
insert into seq100  values (),(),(),(),(),(),(),(),(),();
insert into seq100  values (),(),(),(),(),(),(),(),(),();
insert into seq100  values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x+50 from seq100;
select * from seq100;

create table seq52 as(select x from seq100 limit 52);
select * from seq52;

select distinct x as week_day from seq52 
where x not in (select week_number from clean_weekly_sales);

select distinct week_number from clean_weekly_sales;

## 2.How many total transactions were there for each year in the dataset?
select calender_year
,sum(transactions) as Total_Transaction
from clean_weekly_sales group by calender_year;

## 3.What are the total sales for each region for each month?
select region,month_number,sum(sales) as Total_sales
from clean_weekly_sales
group by month_number,region
order by month_number;

## 4.What is the total count of transactions for each platform
select platform,
sum(transactions) as Total_transactions from clean_weekly_sales
group by platform;

## 5.What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_platform_sales as
(select month_number,calender_year,platform,
sum(sales) as Monthly_sales
from clean_weekly_sales
group by month_number,calender_year,platform)
select month_number,calender_year,
 round(100*max(case when platform='Retail'
 then monthly_sales else null end)/sum(monthly_sales),2)
 as Retail_percentage,
 round(100*max(case when platform='Shopify'
 then monthly_sales else null end)/sum(monthly_sales),2)
 as Shopify_percentage
 from cte_monthly_platform_sales
 group by month_number,calender_year
 order by month_number,calender_year;

 ## 6.What is the percentage of sales by demographic for each year in the dataset?
select calender_year, demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales)) 
over (partition by demographic),2) as percentage
from clean_weekly_sales
group by calender_year,demographic ;

## 7.Which age_band and demographic values contribute the most to Retail sales?
select age_band,demographic,sum(sales) as Total_Sales from clean_weekly_sales
where platform = 'Retail'
group by demographic,age_band
order by Total_Sales desc;

