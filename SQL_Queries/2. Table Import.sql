-- Disable foreign key constraints temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Enable Local File Data Loading
SET GLOBAL local_infile = 1;

-- Run your import query here for category table
LOAD DATA LOCAL INFILE 'C:/Users/kitus/Desktop/Personal Projects/4. Apple Store SQL/Dataset/category.csv'
INTO TABLE category
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Check the table
select * from category;

-- Run your import query here for product table
LOAD DATA LOCAL INFILE 'C:/Users/kitus/Desktop/Personal Projects/4. Apple Store SQL/Dataset/product.csv'
INTO TABLE product
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Check the table
select * from product;

-- Run your import query here for store table
LOAD DATA LOCAL INFILE 'C:/Users/kitus/Desktop/Personal Projects/4. Apple Store SQL/Dataset/stores.csv'
INTO TABLE store
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Check the table
select * from store;

-- Run your import query here for warrenty table
LOAD DATA LOCAL INFILE 'C:/Users/kitus/Desktop/Personal Projects/4. Apple Store SQL/Dataset/warranty.csv'
INTO TABLE warranty
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Check the table
select * from warranty;

LOAD DATA LOCAL INFILE 'C:/Users/kitus/Desktop/Personal Projects/4. Apple Store SQL/Dataset/sales.csv'
INTO TABLE sale
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

select * from sale;

-- Step 3: Turn safety checks back on
SET FOREIGN_KEY_CHECKS = 1;