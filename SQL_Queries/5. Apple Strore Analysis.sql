# Find the number of stores in each country.
select Country,
	   Count(Store_ID) as Total_Stores
from store
group by Country
Order by Total_Stores DESC;



# Calculate the total number of units sold by each store.
CREATE INDEX idx_sale_store_quantity ON sale (store_id, quantity);
-- This index improve from 6533 ms to 4106 ms

select b.Store_ID,
	   b.Store_Name,
	   sum(a.quantity) as Total_Units
from store b left join sale a
on b.store_id = a.store_id
group by b.store_id, b.Store_Name
order by Total_Units;



# Identify how many sales occurred in December 2023 [273 ms to 12.6 ms (a 95.4% speedup)]
select count(sale_id) as Total_Sales
from sale
where year(sale_date) = 2023 and month(sale_date) = 12;
-- Without index range using = 273 ms

-- OR --

select count(sale_id) as Total_Sales
from sale
where sale_date >= '2023-12-01' and sale_date < '2024-01-01';
-- With the index range using = 12.6 ms



# Determine how many stores have never had a warranty claim filed.
select count(st.store_id) as No_Claim_Store
from store st
where not exists (
					select distinct store_id
					from sale s inner join warranty w
					on s.sale_id = w.sale_id);
                    


# Calculate the percentage of warranty claims marked as "Rejected".
select concat(
			round(
				sum(case when repair_status = "Rejected" then 1 else 0 end) *100
                / count(*),2),"%") as Rejected_Pct
from warranty;



# Identify which store had the highest total units sold in the last year
select  a.Store_ID,
		b.Store_Name,
		sum(quantity) as Quantity
from sale a join store b
on a.store_id = b.Store_ID
where year(sale_date) = YEAR((SELECT MAX(sale_date) FROM sale)) - 1
group by store_id
order by Quantity desc
limit 1;



# Count the number of unique products sold in the last year
select count(distinct product_id) as count_of_products
from sale
where year(sale_date) = year((select max(sale_date) from sale)) -1;




# Find the average price of products in each category
select c.category_id,
		c.category_name,
        round(avg(p.price),2) as average
from category c join product p
on c.category_id = p.category_id
group by 1,2
order by 3 desc;



# Find the average sale price of products in each category
select c.category_id,
		c.category_name,
        round((sum(s.quantity*p.price))/sum(s.quantity),2) as average
from category c
join product p on c.category_id = p.Category_ID
join sale s on p.Product_ID = s.product_id
group by 1,2
order by 3 Desc;



# How many warranty claims were filed in Aug 2024?
select count(*) as No_of_Claims
from warranty
where claim_date between '2024-08-01' and '2024-08-31';



# For each store, identify the best-selling date based on highest quantity sold.
select store_id, day
from(
Select store_id,
	   dayname(sale_date) as day,
       sum(quantity),
       rank() over(partition by store_id order by sum(quantity) desc) as rnk
from sale
group by store_id, dayname(sale_date)) as t
where rnk = 1;




# For each store, identify the best-selling date based on highest quantity sold.
with cte as(
select store_id,
		sale_date,
        sum(quantity) as Quantity_Sold,
        dense_rank() over(partition by store_id order by sum(quantity) Desc) as rnk
from sale
group by store_id, sale_date)

select store_id, sale_date
from cte
where rnk = 1;



# Identify the least selling product in each country for each year based on total units sold.
with cte as(
select a.country, -- store
	   c.product_name, -- product
       c.Product_ID, -- product
	   year(b.sale_date) as yr, -- sale
       sum(b.quantity) qt, -- sale
       dense_rank() over(partition by a.country, year(b.sale_date) order by sum(b.quantity) asc) as rk
from store a 
join sale b on a.Store_ID = b.store_id
join product c on b.product_id = c.Product_ID
group by 1,2,3,4)

select Country, Yr as Year, Product_ID, Product_Name
from cte
where rk = 1;



# Calculate how many warranty claims were filed within 180 days of a product sale.
select count(*) as Claim_Under_180days
from sale s join warranty w
on s.sale_id = w.sale_id
where datediff(w.claim_date, s.sale_date) = 180;



# Determine how many warranty claims were filed for products launched in the last two years.
select p.Product_Name, count(w.claim_id) No_Claims, count(s.sale_id) No_Sales,
		concat(round((count(w.claim_id)/count(s.sale_id))*100,2),'%') as `%age Claims`
from product p
join sale s on p.Product_ID = s.product_id
left join warranty w on s.sale_id = w.sale_id
where year(p.Launch_Date) >= (select year(max(Launch_Date) - interval 2 year) from product)
group by p.Product_Name
having count(w.claim_id) > 0
order by 4 desc;



# List the months in the last three years where sales exceeded 5,000 units in the USA.
select date_format(a.sale_date, '%Y-%m') as Month,
		sum(a.quantity) as Sales_Count
from sale a join store b 
on a.store_id = b.Store_ID
where b.Country = "United States" 
and a.sale_year >= (select max(sale_year) - 3 from sale)
group by 1
having Sales_Count >= 5000
order by 2 desc;



# Identify the product category with the most warranty claims filed in the last two years.
select a.Category_ID, 
	   count(c.claim_id) Claim_Count
from product a 
join sale b on a.product_id = b.product_id
join warranty c on b.sale_id = c.sale_id
join (select max(claim_year) - 2  as yr from warranty) as yrs on c.claim_year >= yrs.yr
group by a.Category_ID
order by count(c.claim_id) desc
limit 1;



# Determine the percentage chance of receiving warranty claims after each purchase for each country.
select a.country,
       count(c.claim_id) as Claim_Qnt,
       sum(b.quantity) as Sold_Qnt,
       concat(round((count(c.claim_id)*100/sum(b.quantity)),2),'%') as '%age Claim Chance'
from store a 
left join sale b on a.Store_ID = b.store_id
join warranty c on b.sale_id = c.sale_id
group by a.country
order by 4;



# Analyze the year-by-year growth ratio for each store.
with cte as(
select a.store_Name,
		b.sale_year,
		sum(b.quantity) as current_year_sale,
        lag(sum(b.quantity)) over(partition by a.store_id order by b.sale_year) as Last_year_sale
from store a join sale b 
on a.Store_ID = b.store_id
group by a.Store_ID, b.sale_year)

select Store_Name, Sale_year, Current_year_Sale, Last_year_sale,
	   Round(Current_year_sale/Last_year_sale, 2) as Growth_Ratio
from cte
where Last_Year_Sale is not null;



# Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
select case 
			when price < 750 then 'Less Expensive Product'
			when price between 750 and 1500 then 'Medium Expensive Product'
            else 'Highly expensive Product'
       end as Price_Segment,
	   count(w.claim_id) as Claim_Counts
from product p
join sale s on p.Product_ID = s.Product_ID
join warranty w on s.sale_id = w.sale_id
group by 1;



# Identify the store with the highest percentage of "Pending" claims relative to total claims filed.
with cte as(
select a.Store_Name,
	   sum(case when c.repair_status = 'Pending' then 1 else 0 end) as Pending_Claims,
       count(c.claim_id) as Total_Claim
from store a 
join sale b on a.Store_ID = b.store_id
join warranty c on b.sale_id = c.sale_id
group by 1)

select *, 
	   concat(Round(Pending_Claims/Total_Claim*100,2),'%') '%age Pending'
from cte
order by 4 desc
limit 1;



# Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
select a.Store_Name,
		date_format(b.sale_date, '%Y-%m') as Month_Year,
		sum(sum(p.price * b.quantity)) over(partition by a.Store_Name order by date_format(b.sale_date, '%Y-%m')) as Running_Total
from store a 
join sale b on a.Store_ID = b.store_id
join product p on b.Product_ID = p.Product_ID
join (select max(sale_year) - 3 as yr from sale) as yrs on b.sale_year >= yrs.yr
group by 1,2;



# Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
select a.Product_Name, 
	   case when timestampdiff(Month, a.Launch_date, b.sale_Date) < 6 then "0-6"
			when timestampdiff(Month, a.Launch_date, b.sale_Date) between 6 and 12 then "6-12"
            when timestampdiff(Month, a.Launch_date, b.sale_Date) between 12 and 18 then "12-18"
            else "Beyond 18"
		end as Month_Segments,
        sum(a.price * b.quantity) as Sales
from product a join sale b
on a.Product_ID = b.product_id
group by 1,2
order by 1, min(timestampdiff(month, a.Launch_Date, b.sale_Date));