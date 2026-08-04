-- Creating the Database
create database Apple_db;
use apple_db;

-- Creating the required Tables
create table category(
category_id varchar(10) primary key,
category_name varchar(50));
 
create table store(
Store_ID varchar(10) primary key,
Store_Name varchar(50),
City varchar(25),
Country varchar(25));

create table product(
Product_ID varchar(10) primary key,
Product_Name varchar(50),
Category_ID varchar(10), -- fk
Launch_Date date,
Price float,
constraint fk_category foreign key (category_id) references category(category_id));

create table sale(
sale_id varchar(20) primary key,
sale_date date,
store_id varchar(10), -- fk
product_id varchar(10), -- fk
quantity int,
constraint fk_store foreign key (store_id) references store(store_id),
constraint fk_product foreign key (product_id) references product(product_id));

create table warranty(
claim_id varchar(20) primary key,
claim_date date,
sale_id varchar(20), -- fk
repair_status varchar(20),
constraint fk_sale foreign key (sale_id) references sale(sale_id));