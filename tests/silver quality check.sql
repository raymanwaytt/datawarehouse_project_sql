/*	====== BRONZE crm_cust_info table cleanup ======	*/

-- Duplicate check in the primary key
SELECT 
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR 	cst_id IS NULL;

-- Check for names with trailing space
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization and Consistency
SELECT 
	DISTINCT cst_marital_status
FROM silver.crm_cust_info


/*	====== BRONZE crm_prd_info table cleaning ======	*/

-- checking for NULLS in prd_id
SELECT prd_id
FROM silver.crm_prd_info
WHERE prd_id IS NULL

-- checking for NULLS & whitespaces in prd_id
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm IS NULL OR prd_nm != TRIM(prd_nm)

-- checking to see product key in sales that doesnt match products record
SELECT 
	sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
SELECT 
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
FROM silver.crm_prd_info )

-- checking for NULLS OR Negative number
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization --
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for invalid date
SELECT *
FROM	silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- FIX
SELECT
	prd_id,
    prd_key,
	prd_nm,
    prd_start_dt,
    prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

/*	====== BRONZE crm_prd_info table cleaning ======	*/

-- checking for NULLS and whitespace in sls_prd_key
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key) OR sls_prd_key IS NULL

-- Checking FOR product key in sales that doesnt match prd_key
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

-- Checking for integrity of CustomerID
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Check for invalid date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 OR sls_ship_dt <= 0 OR sls_due_dt <= 0

-- Check for invalid date (> 8 in lenght)
SELECT *
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) > 8 OR LEN(sls_ship_dt) > 8  OR LEN(sls_due_dt) > 8

-- Check for invalid date orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check for invalid sales record
SELECT *
FROM silver.crm_sales_details
WHERE sls_price <= 0 OR sls_quantity <= 0 OR sls_sales <= 0
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR sls_sales != sls_price * sls_quantity

SELECT *
FROM silver.crm_sales_details

/*	====== BRONZE erp_cust_az12 table cleaning ======	*/

SELECT *
FROM bronze.crm_cust_info

SELECT *
FROM bronze.erp_cust_az12

-- Check for Invalid Customer key 
WITH cust_table AS (
SELECT 
	CASE 
		WHEN cid LIKE 'NAS%'
		THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid 
	END AS cid,
	bdate,
	gen
FROM bronze.erp_cust_az12)
SELECT *
FROM cust_table
WHERE cid NOT IN (SELECT DISTINCT cst_key FROM bronze.crm_cust_info)

SELECT cid
FROM silver.erp_cust_az12
--
-- Check for DISTINNCT gen
SELECT 
	DISTINCT gen
FROM silver.erp_cust_az12

-- Check for Invali Bdate range
SELECT 
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

/*	====== SILVER erp_loc_a101 table cleaning ======	*/

-- clean cid and 
-- check for matches in the customer info
SELECT 
	cid
FROM silver.erp_loc_a101
WHERE cid NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization
-- check distinct countries
SELECT
	DISTINCT cntry
FROM silver.erp_loc_a101

SELECT *
FROM silver.erp_loc_a101

/*	====== SILVER erp_px_cat_g1v2 table cleaning ======	*/
SELECT *
FROM bronze.erp_px_cat_g1v2

SELECT * 
FROM silver.crm_prd_info

-- Checking for unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR  subcat != TRIM(subcat) OR  maintenance != TRIM(maintenance)

-- checking for data quality
SELECT 
	DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT 
	DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT 
	DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
