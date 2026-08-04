# 💻 Apple Retail Store — SQL Analysis Project

> End-to-End SQL Project · Data Cleaning · Performance Optimization · Business Analytics

---

## 📌 Project Overview

This project simulates a real-world data analytics workflow on a large-scale Apple retail sales dataset containing over **1 million transactions** across **75 global stores**. The project covers the full analytics pipeline — from database design and data import, through query performance optimization, data quality validation and cleaning, to advanced business analysis using SQL.

The dataset spans Apple product sales from **2019 to 2024** across multiple countries, capturing sales transactions, warranty claims, product catalog, store information, and category data.

### Skills Demonstrated
- Database design with normalized schema and foreign key constraints
- Bulk data import using `LOAD DATA LOCAL INFILE`
- Index creation and query performance optimization (`EXPLAIN ANALYZE`)
- Data quality auditing and cleaning using business rules
- Advanced SQL: JOINs, CTEs, Window Functions, Aggregations, Subqueries
- Virtual computed columns for performance on repeated expressions

---

## 👨‍💼 Business Value & Stakeholder Insights

This project addresses real business problems across five functional areas:

**Sales & Revenue Teams**
- Which stores and countries are driving the highest volume, and which are chronically underperforming?
- Is revenue growing year over year at the store level, or are certain locations in decline?
- Which products generate the most revenue relative to their list price — and which are dragging down averages?
- What does the monthly revenue curve look like per store, and are seasonal peaks consistent across years?

**Product & Category Management**
- Do products sell strongly immediately after launch, or does demand build gradually over time?
- Which categories command the highest weighted average sale price when actual units sold are factored in?
- Which products are consistently the least sold across key markets every year — candidates for discontinuation or repositioning?
- How does sales velocity change across a product's lifecycle — 0–6 months, 6–12, 12–18, and beyond?

**After-Sales & Warranty Operations**
- What is the probability of a warranty claim occurring after a purchase, and does it vary significantly by country?
- Are higher-priced products more failure-prone than budget ones — or do cheaper products generate more claims per unit sold?
- Which stores have the highest backlog of unresolved "Pending" claims — a signal of service capacity issues?
- What proportion of claims are being outright "Rejected" — and could that indicate a documentation or eligibility problem?
- How many claims arrive within 180 days of purchase — an indicator of early product failure rates?

**Supply Chain & Store Operations**
- Which day of the week consistently sees the highest sales per store — actionable for staffing rosters and stock replenishment cycles?
- Which months in key markets like the USA breach high-volume thresholds — critical for demand forecasting and inventory pre-positioning?
- Which store had the single best-performing sales date, and what product mix drove it?
- How many stores have never received a warranty claim — and does that correlate with their sales volume or product mix?

**Data Quality & Engineering**
- Can we trust the data before we build dashboards on top of it? This project demonstrates a full audit-first approach — validating business rules before any analysis is run.
- How do you handle cascading deletes in a relational database — removing 493K invalid sales without breaking dependent warranty records?
- How do hidden characters in categorical fields silently corrupt GROUP BY results — and how do you detect and fix them?
- How do indexes and virtual computed columns reduce query time by up to 70% on million-row tables?

---

## 📂 Dataset

| Table | Rows | Description |
|---|---|---|
| `store` | 75 | Apple retail locations — store name, city, country |
| `category` | 10 | Product categories (Laptop, Audio, Phone, etc.) |
| `product` | 89 | Product catalog with launch date and price |
| `sale` | 1,040,201 | Individual sales transactions (post-cleaning) |
| `warranty` | 30,000 | Warranty claims with repair status |

> **Note:** The original dataset contained 493,143 invalid sales records (sold before product launch date) and 2,511 invalid warranty claims (claimed before purchase date), which were identified and removed during the data cleaning phase.

---

## 🗂️ Schema Design

```
category  (category_id PK, category_name)
    │
product   (product_id PK, product_name, category_id FK, launch_date, price)
    │
store     (store_id PK, store_name, city, country)
    │
sale      (sale_id PK, sale_date, store_id FK, product_id FK, quantity)
    │
warranty  (claim_id PK, claim_date, sale_id FK, repair_status)
```

---

## 🗂️ Entity Relationship Diagram (ERD)

The following ERD illustrates the database schema used in this project, showing the relationships between all tables involved in the Apple Retail Store database.

<p align="center">
  <img src="./ERR Diagram.png" alt="Apple Retail Store ER Diagram" width="850">
</p>

---

## 📁 Project Structure

```
Apple-Store-SQL-Analysis/
├── 1__Database_and_Table_Creation.sql
├── 2__Table_Import.sql
├── 3__Query_Performance_Increase.sql
├── 4__Data_Cleaning.sql
├── 5__Apple_Store_Analysis.sql
├── Apple_DB_Observations.txt
└── README.md
```

---

## Part 1 — Database & Table Creation

Created the `Apple_DB` database and five normalized tables with appropriate data types, primary keys, and foreign key constraints.

```sql
CREATE DATABASE Apple_db;
USE Apple_db;

CREATE TABLE category (
    category_id   VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE store (
    store_id   VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(50),
    city       VARCHAR(25),
    country    VARCHAR(25)
);

CREATE TABLE product (
    product_id   VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(50),
    category_id  VARCHAR(10),
    launch_date  DATE,
    price        FLOAT,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE sale (
    sale_id    VARCHAR(20) PRIMARY KEY,
    sale_date  DATE,
    store_id   VARCHAR(10),
    product_id VARCHAR(10),
    quantity   INT,
    CONSTRAINT fk_store   FOREIGN KEY (store_id)   REFERENCES store(store_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE warranty (
    claim_id      VARCHAR(20) PRIMARY KEY,
    claim_date    DATE,
    sale_id       VARCHAR(20),
    repair_status VARCHAR(20),
    CONSTRAINT fk_sale FOREIGN KEY (sale_id) REFERENCES sale(sale_id)
);
```

---

## Part 2 — Data Import

```sql
SET FOREIGN_KEY_CHECKS = 0;
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'path/to/category.csv'
INTO TABLE category FIELDS TERMINATED BY ',' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'path/to/product.csv'
INTO TABLE product  FIELDS TERMINATED BY ',' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'path/to/stores.csv'
INTO TABLE store    FIELDS TERMINATED BY ',' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'path/to/warranty.csv'
INTO TABLE warranty FIELDS TERMINATED BY ',' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'path/to/sales.csv'
INTO TABLE sale     FIELDS TERMINATED BY ',' IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;
```

---

## Part 3 — Query Performance Optimization

Used `EXPLAIN ANALYZE` to benchmark before and after index creation.

| Index | Column(s) | Before | After | Speedup |
|---|---|---|---|---|
| `sale_product_id` | `sale(product_id)` | 8.51 ms | 4.80 ms | 43.6% |
| `sale_store_id` | `sale(store_id)` | 8.33 ms | 5.47 ms | 34.3% |
| `sale_sale_date` | `sale(sale_date)` | 1,259 ms | 465 ms | 63.1% |
| `warranty_repair_status` | `warranty(repair_status)` | 57.7 ms | 25.2 ms | 56.3% |
| `warranty_claim_date` | `warranty(claim_date)` | 53.4 ms | 16.0 ms | 70.0% |

**Virtual Computed Columns** were added to avoid repeated `YEAR()` function calls on large scans:

```sql
ALTER TABLE sale
    ADD COLUMN sale_year INT GENERATED ALWAYS AS (YEAR(sale_date)) VIRTUAL;

ALTER TABLE warranty
    ADD COLUMN claim_year INT GENERATED ALWAYS AS (YEAR(claim_date)) VIRTUAL;

CREATE INDEX idx_sale_virtual_year     ON sale     (sale_year,  sale_id,  store_id);
CREATE INDEX idx_warranty_virtual_year ON warranty (claim_year, sale_id,  claim_id);
```

---

## Part 4 — Data Quality Validation & Cleaning

### Issue 1 — Sales Recorded Before Product Launch Date

```sql
-- Identify violations
SELECT COUNT(*) AS invalid_sales
FROM sale s
JOIN product p ON s.product_id = p.product_id
WHERE s.sale_date < p.launch_date;
-- Result: 493,143 invalid records

-- Step 1: Delete dependent warranty records first
DELETE w
FROM warranty w
JOIN sale s    ON w.sale_id    = s.sale_id
JOIN product p ON s.product_id = p.product_id
WHERE s.sale_date < p.launch_date;
-- Records deleted: 14,330

-- Step 2: Delete invalid sales
DELETE s
FROM sale s
JOIN product p ON s.product_id = p.product_id
WHERE s.sale_date < p.launch_date;
-- Records deleted: 493,143
```

### Issue 2 — Warranty Claims Before Purchase Date

```sql
-- Identify violations
SELECT COUNT(*) AS invalid_warranty_claims
FROM warranty w
JOIN sale s ON w.sale_id = s.sale_id
WHERE w.claim_date < s.sale_date;
-- Result: 2,511 invalid records

-- Clean
DELETE w
FROM warranty w
JOIN sale s ON w.sale_id = s.sale_id
WHERE w.claim_date < s.sale_date;
-- Records deleted: 2,511
```

### Issue 3 — Hidden Characters in repair_status

```sql
-- Investigate
SELECT DISTINCT repair_status, LENGTH(repair_status) AS character_count
FROM warranty;

-- Fix: strip carriage returns and newlines
UPDATE warranty
SET repair_status = REPLACE(REPLACE(repair_status, '\r', ''), '\n', '');
```

### Cleaning Summary

| Issue | Records Affected | Action |
|---|---|---|
| Sales before product launch | 493,143 | Deleted |
| Warranty claims from deleted sales | 14,330 | Deleted (cascade) |
| Warranty claims before purchase date | 2,511 | Deleted |
| Warranty claims before product launch | 0 | No action needed |
| Hidden characters in repair_status | All rows | REPLACE() cleanup |

---

## Part 5 — Business Analysis Queries

### Q1. Number of Stores in Each Country

```sql
SELECT Country,
       COUNT(Store_ID) AS Total_Stores
FROM store
GROUP BY Country
ORDER BY Total_Stores DESC;
```

### Q2. Total Units Sold by Each Store

```sql
SELECT b.Store_ID,
       b.Store_Name,
       SUM(a.quantity) AS Total_Units
FROM store b
LEFT JOIN sale a ON b.store_id = a.store_id
GROUP BY b.store_id, b.Store_Name
ORDER BY Total_Units;
```

### Q3. Total Sales in December 2023

Two approaches — the second uses index range scanning for a **95.4% speedup** (273 ms → 12.6 ms).

```sql
-- Approach 1: YEAR() + MONTH() functions (slower)
SELECT COUNT(sale_id) AS Total_Sales
FROM sale
WHERE YEAR(sale_date) = 2023 AND MONTH(sale_date) = 12;

-- Approach 2: Date range — index-friendly (faster)
SELECT COUNT(sale_id) AS Total_Sales
FROM sale
WHERE sale_date >= '2023-12-01' AND sale_date < '2024-01-01';
```

### Q4. Stores That Have Never Had a Warranty Claim

```sql
SELECT COUNT(st.store_id) AS No_Claim_Store
FROM store st
WHERE NOT EXISTS (
    SELECT DISTINCT store_id
    FROM sale s
    INNER JOIN warranty w ON s.sale_id = w.sale_id
);
```

### Q5. Percentage of Warranty Claims Marked as "Rejected"

```sql
SELECT CONCAT(
    ROUND(
        SUM(CASE WHEN repair_status = "Rejected" THEN 1 ELSE 0 END) * 100
        / COUNT(*), 2),
    '%') AS Rejected_Pct
FROM warranty;
```

### Q6. Store with Highest Total Units Sold in the Last Year

```sql
SELECT  a.Store_ID,
        b.Store_Name,
        SUM(quantity) AS Quantity
FROM sale a
JOIN store b ON a.store_id = b.Store_ID
WHERE YEAR(sale_date) = YEAR((SELECT MAX(sale_date) FROM sale)) - 1
GROUP BY store_id
ORDER BY Quantity DESC
LIMIT 1;
```

### Q7. Number of Unique Products Sold in the Last Year

```sql
SELECT COUNT(DISTINCT product_id) AS count_of_products
FROM sale
WHERE YEAR(sale_date) = YEAR((SELECT MAX(sale_date) FROM sale)) - 1;
```

### Q8. Average List Price of Products in Each Category

```sql
SELECT c.category_id,
       c.category_name,
       ROUND(AVG(p.price), 2) AS average
FROM category c
JOIN product p ON c.category_id = p.category_id
GROUP BY 1, 2
ORDER BY 3 DESC;
```

### Q9. Weighted Average Sale Price of Products in Each Category

Accounts for actual units sold rather than just list price average.

```sql
SELECT c.category_id,
       c.category_name,
       ROUND(SUM(s.quantity * p.price) / SUM(s.quantity), 2) AS average
FROM category c
JOIN product p ON c.category_id  = p.Category_ID
JOIN sale    s ON p.Product_ID   = s.product_id
GROUP BY 1, 2
ORDER BY 3 DESC;
```

### Q10. Warranty Claims Filed in August 2024

```sql
SELECT COUNT(*) AS No_of_Claims
FROM warranty
WHERE claim_date BETWEEN '2024-08-01' AND '2024-08-31';
```

### Q11. Best-Selling Day of Week per Store (Window Function — RANK)

```sql
SELECT store_id, day
FROM (
    SELECT store_id,
           DAYNAME(sale_date) AS day,
           SUM(quantity),
           RANK() OVER (PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rnk
    FROM sale
    GROUP BY store_id, DAYNAME(sale_date)
) AS t
WHERE rnk = 1;
```

### Q12. Best-Selling Specific Date per Store (CTE + Window Function — DENSE_RANK)

```sql
WITH cte AS (
    SELECT store_id,
           sale_date,
           SUM(quantity) AS Quantity_Sold,
           DENSE_RANK() OVER (PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rnk
    FROM sale
    GROUP BY store_id, sale_date
)
SELECT store_id, sale_date
FROM cte
WHERE rnk = 1;
```

### Q13. Least-Selling Product per Country per Year (CTE + Window Function)

```sql
WITH cte AS (
    SELECT a.country,
           c.product_name,
           c.Product_ID,
           YEAR(b.sale_date)  AS yr,
           SUM(b.quantity)    AS qt,
           DENSE_RANK() OVER (
               PARTITION BY a.country, YEAR(b.sale_date)
               ORDER BY SUM(b.quantity) ASC
           ) AS rk
    FROM store   a
    JOIN sale    b ON a.Store_ID   = b.store_id
    JOIN product c ON b.product_id = c.Product_ID
    GROUP BY 1, 2, 3, 4
)
SELECT Country, Yr AS Year, Product_ID, Product_Name
FROM cte
WHERE rk = 1;
```

### Q14. Warranty Claims Filed Within 180 Days of Sale

```sql
SELECT COUNT(*) AS Claim_Under_180days
FROM sale s
JOIN warranty w ON s.sale_id = w.sale_id
WHERE DATEDIFF(w.claim_date, s.sale_date) <= 180;
```

### Q15. Warranty Claim Rate for Products Launched in the Last Two Years

```sql
SELECT p.Product_Name,
       COUNT(w.claim_id)                                              AS No_Claims,
       COUNT(s.sale_id)                                               AS No_Sales,
       CONCAT(ROUND(COUNT(w.claim_id) / COUNT(s.sale_id) * 100, 2), '%') AS "%age Claims"
FROM product p
JOIN sale    s ON p.Product_ID = s.product_id
LEFT JOIN warranty w ON s.sale_id = w.sale_id
WHERE YEAR(p.Launch_Date) >= (
    SELECT YEAR(MAX(Launch_Date) - INTERVAL 2 YEAR) FROM product
)
GROUP BY p.Product_Name
HAVING COUNT(w.claim_id) > 0
ORDER BY 4 DESC;
```

### Q16. Months Where USA Sales Exceeded 5,000 Units (Last 3 Years)

```sql
SELECT DATE_FORMAT(a.sale_date, '%Y-%m') AS Month,
       SUM(a.quantity)                   AS Sales_Count
FROM sale  a
JOIN store b ON a.store_id = b.Store_ID
WHERE b.Country = 'United States'
  AND a.sale_year >= (SELECT MAX(sale_year) - 3 FROM sale)
GROUP BY 1
HAVING Sales_Count >= 5000
ORDER BY 2 DESC;
```

### Q17. Product Category with Most Warranty Claims in the Last Two Years

```sql
SELECT a.Category_ID,
       COUNT(c.claim_id) AS Claim_Count
FROM product  a
JOIN sale     b  ON a.product_id = b.product_id
JOIN warranty c  ON b.sale_id    = c.sale_id
JOIN (SELECT MAX(claim_year) - 2 AS yr FROM warranty) AS yrs
     ON c.claim_year >= yrs.yr
GROUP BY a.Category_ID
ORDER BY Claim_Count DESC
LIMIT 1;
```

### Q18. Warranty Claim Probability by Country

```sql
SELECT a.country,
       COUNT(c.claim_id) AS Claim_Qnt,
       SUM(b.quantity)   AS Sold_Qnt,
       CONCAT(ROUND(COUNT(c.claim_id) * 100 / SUM(b.quantity), 2), '%') AS "%age Claim Chance"
FROM store    a
LEFT JOIN sale    b ON a.Store_ID = b.store_id
JOIN      warranty c ON b.sale_id  = c.sale_id
GROUP BY a.country
ORDER BY 4;
```

### Q19. Year-by-Year Sales Growth Ratio per Store (CTE + LAG Window Function)

```sql
WITH cte AS (
    SELECT a.store_Name,
           b.sale_year,
           SUM(b.quantity) AS current_year_sale,
           LAG(SUM(b.quantity)) OVER (
               PARTITION BY a.store_id
               ORDER BY b.sale_year
           ) AS Last_year_sale
    FROM store a
    JOIN sale b ON a.Store_ID = b.store_id
    GROUP BY a.Store_ID, b.sale_year
)
SELECT Store_Name,
       Sale_year,
       Current_year_Sale,
       Last_year_sale,
       ROUND(Current_year_sale / Last_year_sale, 2) AS Growth_Ratio
FROM cte
WHERE Last_Year_Sale IS NOT NULL;
```

### Q20. Warranty Claims by Product Price Segment

```sql
SELECT CASE
           WHEN price < 750                THEN 'Less Expensive Product'
           WHEN price BETWEEN 750 AND 1500 THEN 'Medium Expensive Product'
           ELSE                                  'Highly Expensive Product'
       END               AS Price_Segment,
       COUNT(w.claim_id) AS Claim_Counts
FROM product  p
JOIN sale     s ON p.Product_ID = s.Product_ID
JOIN warranty w ON s.sale_id    = w.sale_id
GROUP BY 1;
```

### Q21. Store with Highest Percentage of "Pending" Warranty Claims (CTE)

```sql
WITH cte AS (
    SELECT a.Store_Name,
           SUM(CASE WHEN c.repair_status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Claims,
           COUNT(c.claim_id)                                              AS Total_Claim
    FROM store    a
    JOIN sale     b ON a.Store_ID = b.store_id
    JOIN warranty c ON b.sale_id  = c.sale_id
    GROUP BY 1
)
SELECT *,
       CONCAT(ROUND(Pending_Claims / Total_Claim * 100, 2), '%') AS "%age Pending"
FROM cte
ORDER BY 4 DESC
LIMIT 1;
```

### Q22. Monthly Running Total of Sales Revenue per Store — Last 4 Years (Window Function)

```sql
SELECT a.Store_Name,
       DATE_FORMAT(b.sale_date, '%Y-%m') AS Month_Year,
       SUM(SUM(p.price * b.quantity)) OVER (
           PARTITION BY a.Store_Name
           ORDER BY DATE_FORMAT(b.sale_date, '%Y-%m')
       ) AS Running_Total
FROM store   a
JOIN sale    b  ON a.Store_ID   = b.store_id
JOIN product p  ON b.Product_ID = p.Product_ID
JOIN (SELECT MAX(sale_year) - 3 AS yr FROM sale) AS yrs
     ON b.sale_year >= yrs.yr
GROUP BY 1, 2;
```

### Q23. Product Sales Trend Segmented by Months Since Launch

```sql
SELECT a.Product_Name,
       CASE
           WHEN TIMESTAMPDIFF(MONTH, a.Launch_date, b.sale_Date) < 6          THEN '0-6 Months'
           WHEN TIMESTAMPDIFF(MONTH, a.Launch_date, b.sale_Date) BETWEEN 6
                AND 12                                                          THEN '6-12 Months'
           WHEN TIMESTAMPDIFF(MONTH, a.Launch_date, b.sale_Date) BETWEEN 12
                AND 18                                                          THEN '12-18 Months'
           ELSE                                                                      'Beyond 18 Months'
       END                       AS Month_Segments,
       SUM(a.price * b.quantity) AS Sales
FROM product a
JOIN sale b ON a.Product_ID = b.product_id
GROUP BY 1, 2
ORDER BY 1, MIN(TIMESTAMPDIFF(MONTH, a.Launch_Date, b.sale_Date));
```

---

## SQL Concepts Coverage

| Concept | Queries |
|---|---|
| JOINs (INNER, LEFT) | Q2, Q6, Q8, Q9, Q13, Q15, Q16, Q17, Q18, Q19, Q22, Q23 |
| GROUP BY + Aggregation | Q1, Q2, Q3, Q5, Q8, Q9, Q10, Q14, Q17, Q18, Q20 |
| CTE (WITH clause) | Q12, Q13, Q19, Q21 |
| Window Functions (RANK, DENSE_RANK, LAG, Running SUM) | Q11, Q12, Q13, Q19, Q22 |
| Subqueries | Q6, Q7, Q15, Q16, Q17 |
| CASE / Conditional Logic | Q5, Q20, Q21, Q23 |
| Date Functions (DATEDIFF, TIMESTAMPDIFF, DATE_FORMAT) | Q3, Q10, Q14, Q15, Q16, Q23 |

---

## ▶️ How to Run This Project

**Prerequisites:** MySQL 8.0+ with `local_infile` enabled.

1. Run `1__Database_and_Table_Creation.sql` — creates `Apple_db` and all 5 tables
2. Update file paths in `2__Table_Import.sql`, then run it to load all CSV data
3. Run `3__Query_Performance_Increase.sql` — creates all indexes and virtual columns
4. Run `4__Data_Cleaning.sql` — validates and removes all invalid records
5. Run `5__Apple_Store_Analysis.sql` — execute all 23 business analysis queries

---

## 👤 Author

**Subhabrata**
- GitHub: [github.com/SpartanSubha](https://github.com/SpartanSubha)
- LinkedIn: [linkedin.com/in/subhabrata99](https://linkedin.com/in/subhabrata99)
- Email: kitusahoo@gmail.com

*This project is part of a data analytics portfolio demonstrating end-to-end SQL skills applicable to Data Analyst, Business Analyst, and MIS Analyst roles.*
