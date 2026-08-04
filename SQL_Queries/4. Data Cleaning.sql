# Issue 1: Sales Recorded Before Product Launch

SELECT COUNT(*) AS invalid_sales 
FROM sale s JOIN product p 
ON s.product_id = p.product_id 
WHERE s.sale_date < p.launch_date;
# Observation: - 493,143 invalid sales records identified.

 -- Delete dependent warranty records
DELETE w 
FROM warranty w JOIN sale s 
ON w.sale_id = s.sale_id JOIN product p 
ON s.product_id = p.product_id WHERE s.sale_date < p.launch_date;
# Records deleted: 14,330

-- Delete invalid sales records
DELETE s 
FROM sale s JOIN product p 
ON s.product_id = p.product_id 
WHERE s.sale_date < p.launch_date;
# Records deleted: 493,143

-- Validation:
SELECT COUNT(*) AS remaining_invalid_sales 
FROM sale s JOIN product p 
ON s.product_id = p.product_id 
WHERE s.sale_date < p.launch_date;


# Issue 2: Warranty Claims Before Purchase Date

SELECT COUNT(*) AS invalid_warranty_claims 
FROM warranty w JOIN sale s
ON w.sale_id = s.sale_id 
WHERE w.claim_date < s.sale_date;
# Observation: - 2,511 invalid warranty claims identified.

-- Cleaning:
DELETE w FROM warranty w JOIN sale s ON w.sale_id = s.sale_id WHERE
w.claim_date < s.sale_date;
# Records deleted: 2,511

-- Validation:
SELECT COUNT(*) AS remaining_invalid_claims 
FROM warranty w JOIN sale s
ON w.sale_id = s.sale_id 
WHERE w.claim_date < s.sale_date;




# Issue 3: Warranty Claims Before Product Launch

SELECT COUNT(*) AS claims_before_launch 
FROM warranty w 
JOIN sale s ON w.sale_id = s.sale_id 
JOIN product p ON s.product_id = p.product_id
WHERE w.claim_date < p.launch_date;
# Observation: - No invalid records remained after previous cleaning.


# Issue Faced: Hidden characters in repair_status. 
# Investigation:
SELECT DISTINCT repair_status, LENGTH(repair_status) AS character_count FROM warranty;

# Resolution: 
UPDATE warranty SET repair_status = REPLACE(REPLACE(repair_status, '\r',''),'\n','');