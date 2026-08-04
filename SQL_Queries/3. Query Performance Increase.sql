-- Improving Query Performance (By Creating Index)

# Sale Table > Product_Id

explain analyze 
select count(*)
from sale
where product_id = 'P-31';
# 8.51 ms

create index sale_product_id on sale(product_id);

explain analyze 
select count(*)
from sale
where product_id = 'P-31';
# 4.80 ms

/*
This new index (sale_product_id) dropped 
the total execution time from 8.51 ms to 4.80 ms (a 43.6% speedup),
primarily by cutting data retrieval time in half.
*/



# Sale Table > Store_Id

explain analyze
select count(*)
from sale
where store_id = 'ST-67';
# 8.33 ms

create index sale_store_id on sale(store_id);

explain analyze
select count(*)
from sale
where store_id = 'ST-67';
# 5.47 ms

/*
The new index (sale_store_id) reduced 
the total execution time from 8.33 ms to 5.47 ms (a 34.3% speedup),
primarily by improving the efficiency of the covering index lookup and reducing data retrieval time.
*/



# Sale Table > Sale Date

explain analyze
select month(Sale_date),
	   count(Sale_id)
from sale
group by month(sale_date);
# 1259 ms

create index sale_sale_date on sale(sale_date);

explain analyze
select month(Sale_date),
	   count(Sale_id)
from sale
group by month(sale_date);
# 465 ms

/*
The new index (sale_sale_date) reduced the 
total execution time from 1259 ms to 465 ms (a 63.1% speedup),
primarily by replacing the full table scan with a covering index scan,
significantly reducing data access time during aggregation.
*/



# Warranty Table > Repair Status

explain analyze
select repair_status,
	   count(*)
from warranty
group by repair_status;
# 57.7 ms

create index warranty_repair_status on warranty(repair_status);

explain analyze
select repair_status,
	   count(*)
from warranty
group by repair_status;
# 25.2 ms

/*
The new index (warranty_repair_status) reduced the 
total execution time from 57.7 ms to 25.2 ms (a 56.3% speedup),
primarily by replacing a full table scan and temporary table aggregation
with a covering index scan and direct group aggregation.
*/



# Warranty Table > Claim Date

explain analyze
select month(claim_date),
	   count(claim_id)
from warranty
group by month(claim_date);
# 53.4 ms

create index warranty_claim_date on warranty(claim_date);

explain analyze
select month(claim_date),
	   count(claim_id)
from warranty
group by month(claim_date);
# 16 ms

/*
The new index (warranty_claim_date) reduced 
the total execution time from 53.4 ms to 16.0 ms (a 70.0% speedup), 
primarily by replacing the full table scan with a covering index scan, 
significantly improving data retrieval during aggregation.
*/


-- Speeds up the date filtering and the table join
CREATE INDEX idx_sale_date_store ON sale (sale_date, store_id);

-- Speeds up the country filter
CREATE INDEX idx_store_country ON store (Country, Store_ID);

-- Index on sale_id and product_id
create index idx_sale_prod on sale (sale_id, product_id);

-- Add a virtual column for the sale year
alter table sale add column sale_year int generated always as (year(sale_date)) virtual;

-- Add a virtual column for the claim year
alter table warranty add column claim_year int generated always as (year(claim_date)) virtual;

-- Index on claim year
CREATE INDEX idx_sale_virtual_year ON sale (sale_year, sale_id, store_id);

-- Index on claim year
CREATE INDEX idx_warranty_virtual_year ON warranty (claim_year, sale_id, claim_id);
