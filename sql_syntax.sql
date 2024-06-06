CREATE DATABASE adidas_sales;

CREATE TABLE sales_data (
	retailer VARCHAR(225),
	retailer_id	INT,
    invoice_date DATE,	
    region MEDIUMTEXT,
    state VARCHAR(225),
    city VARCHAR(225),
    product	VARCHAR(225),
    price_per_unit	VARCHAR(225),
    units_sold	DOUBLE,
    total_sales	VARCHAR(225),
    operating_profit VARCHAR(225),
    operating_margin VARCHAR(225),
    sales_method VARCHAR(225)
);

SELECT COUNT(*) AS total_rows
FROM sales_data;


SELECT "blank_nullretailer" AS column_name, COUNT(*) AS value_count FROM sales_data WHERE sales_data.retailer IS NULL OR sales_data.retailer = ''
UNION ALL
SELECT "blank_nullretailer_id" , COUNT(*) FROM sales_data WHERE sales_data.retailer_id IS NULL OR sales_data.retailer_id = ''
UNION ALL
SELECT "blank_nullinvoice_date" , COUNT(*) FROM sales_data WHERE sales_data.invoice_date IS NULL 
UNION ALL
SELECT "blank_nullregion" , COUNT(*) FROM sales_data WHERE sales_data.region IS NULL OR sales_data.region = ''
UNION ALL
SELECT "blank_nullstate" , COUNT(*) FROM sales_data WHERE sales_data.state IS NULL OR sales_data.state = ''
UNION ALL
SELECT "blank_nullcity" , COUNT(*) FROM sales_data WHERE sales_data.city IS NULL OR sales_data.city = ''
UNION ALL
SELECT "blank_nullproduct" , COUNT(*) FROM sales_data WHERE sales_data.product IS NULL OR sales_data.product = ''
UNION ALL
SELECT "blank_nullprice_per_unit" , COUNT(*) FROM sales_data WHERE sales_data.price_per_unit IS NULL OR sales_data.price_per_unit = ''
UNION ALL
SELECT "blank_nullunits_sold" , COUNT(*) FROM sales_data WHERE sales_data.units_sold IS NULL OR sales_data.units_sold = ''
UNION ALL
SELECT "blank_nulltotal_sales" , COUNT(*) FROM sales_data WHERE sales_data.total_sales IS NULL OR sales_data.total_sales = ''
UNION ALL
SELECT "blank_nulloperating_profit" , COUNT(*) FROM sales_data WHERE sales_data.operating_profit IS NULL OR sales_data.operating_profit=''
UNION ALL
SELECT "blank_nulloperating_margin" , COUNT(*) FROM sales_data WHERE sales_data.operating_margin IS NULL OR sales_data.operating_margin = ''
UNION ALL
SELECT "blank_nullsales_method" , COUNT(*) FROM sales_data WHERE sales_data.sales_method IS NULL OR sales_data.operating_margin = '';


SELECT COUNT(*) AS total_duplicate_rows
FROM 
sales_data	
GROUP BY 
	retailer, 
	retailer_id, 
	invoice_date,
	region, 
	state,
	city, 
	product, 
	price_per_unit,
	units_sold, 
	total_sales,
	operating_profit, 
	operating_margin,
	sales_method
HAVING COUNT(*) = 0; 

SELECT (COUNT(*)/(SELECT COUNT(*) FROM sales_data)*100) AS percentage_inconsistent_count
FROM 
	(
    SELECT retailer, 
	retailer_id, 
	invoice_date, 
	region, 
	state, 
	city, 
	product, 
	price_per_unit,  
	units_sold,  
	total_sales, 
	operating_profit,
    operating_margin,
	sales_method
    FROM sales_data
    WHERE retailer = '' OR
		retailer_id = '' OR
        invoice_date IS NULL OR
        region = '' OR
        state = '' OR
        city = '' OR
        product = '' OR
        price_per_unit = '' OR
        units_sold = '' OR
        total_sales = '' OR
        operating_profit = '' OR
        operating_margin = '' OR
        sales_method = '' 
) AS detail_blank_rows;

SELECT retailer, COUNT(*) AS no_of_sales 
FROM sales_data
GROUP BY retailer;

SELECT sales_method, COUNT(*) AS no_of_sales_method
FROM sales_data
GROUP BY sales_method;

SELECT product, COUNT(*) AS no_of_product
FROM sales_data
GROUP BY product;

CREATE TABLE sales_data_1 AS
SELECT * FROM sales_data;

DELETE FROM sales_data_1
WHERE units_sold = '';

UPDATE sales_data_1
SET total_sales = REPLACE(total_sales, ",","");

UPDATE sales_data_1
SET operating_profit = REPLACE(operating_profit, ",","");

UPDATE sales_data_1
SET operating_margin = REPLACE(operating_margin, "%","");

SELECT COUNT(*) FROM sales_data_1;

SELECT YEAR(invoice_date) AS Year, SUM(total_sales) AS sum_of_sales
FROM sales_data_1
GROUP BY Year;


SELECT 
	retailer, 
	SUM(total_sales) AS sum_of_sales, 
	YEAR(invoice_date) AS Year
FROM sales_data_1
WHERE YEAR(invoice_date) = '2020'
GROUP BY retailer, Year
ORDER BY sum_of_sales DESC;

SELECT 
	retailer, 
	SUM(total_sales) AS sum_of_sales, 
	YEAR(invoice_date) AS Year
FROM sales_data_1
WHERE YEAR(invoice_date) = '2021'
GROUP BY retailer, Year
ORDER BY sum_of_sales DESC;

-- What are the top5 product over year?
SELECT product, 
	SUM(total_sales) AS sum_of_sales,
	YEAR(invoice_date) AS Year
FROM 
	sales_data_1
WHERE 
	YEAR(invoice_date) = '2020'
GROUP BY product, Year
ORDER BY sum_of_sales DESC
LIMIT 5;

SELECT product, 
	SUM(total_sales) AS sum_of_sales,
	YEAR(invoice_date) AS Year
FROM 
	sales_data_1
WHERE 
	YEAR(invoice_date) = '2021'
GROUP BY product, Year
ORDER BY sum_of_sales DESC
LIMIT 5;

-- What is the average daily sales value by retailer?
SELECT 
	retailer,
    ROUND(AVG(CASE WHEN YEAR(invoice_date) = '2020' THEN total_sales ELSE 0 END),0) AS avg_2020_sales,
	ROUND(AVG(CASE WHEN YEAR(invoice_date) = '2021' THEN total_sales ELSE 0 END),0) AS avg_2021_sales
FROM
	sales_data_1
GROUP BY retailer;    


-- What are the top region/ state/ city for sales?
DELIMITER //

CREATE PROCEDURE top_sales_by_area_and_year (
    IN area_level VARCHAR(225),
    IN year1 INT,
    IN year2 INT
)
BEGIN
    SET @query = CONCAT(
        "(SELECT ",
        area_level, " , ",
        "SUM(total_sales) AS sum_of_sales, ",
        "YEAR(invoice_date) AS year ",
        "FROM sales_data_1 ",
        "WHERE YEAR(invoice_date) = ", year1, " ",
        "GROUP BY ", area_level, ", year ",
        "ORDER BY sum_of_sales DESC ",
        "LIMIT 1) ",
        "UNION ",
        "(SELECT ",
        area_level, " , ",
        "SUM(total_sales) AS sum_of_sales, ",
        "YEAR(invoice_date) AS year ",
        "FROM sales_data_1 ",
        "WHERE YEAR(invoice_date) = ", year2, " ",
        "GROUP BY ", area_level, ", year ",
        "ORDER BY sum_of_sales DESC ",
        "LIMIT 1)"
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;
CALL  top_sales_by_area_and_year('city', 2020, 2021);
CALL top_sales_by_area_and_year('state', 2020, 2021);
CALL top_sales_by_area_and_year('region', 2020, 2021);

-- What Sales methods are the top 3 for sales?
SELECT 
	sales_method,
	SUM(CASE WHEN YEAR(invoice_date) = '2020' THEN total_sales ELSE 0 END) AS 2020_sales,
	SUM(CASE WHEN YEAR(invoice_date) = '2021' THEN total_sales ELSE 0 END) AS 2021_sales
FROM sales_data_1
GROUP BY sales_method;

-- Which categories of product are the most popular(apparel/ footwear)?

SELECT 
	product_by_ca,
    SUM(CASE WHEN year = '2020' THEN units_sold ELSE 0 END) AS 2020_units_sold,
	SUM(CASE WHEN year = '2021' THEN units_sold ELSE 0 END) AS 2021_units_sold
FROM
	(
	SELECT 
		CASE 
			WHEN product LIKE "%Apparel" THEN "Apparel"
			WHEN product LIKE "%Footwear" THEN "Footwear"
		END AS product_by_ca,
        YEAR(invoice_date) AS year,
        units_sold
      FROM sales_data_1  
    ) AS product_sold
GROUP BY product_by_ca;    

-- What is the profit margin for different product or categories?
SELECT 	
		product,
        ROUND(AVG(CASE WHEN YEAR(invoice_date) = '2020' THEN operating_margin END),2) AS 2020_profit_margin,
		ROUND(AVG(CASE WHEN YEAR(invoice_date) = '2021' THEN operating_margin END),2) AS 2021_profit_margin
FROM
	sales_data_1
GROUP BY product;    
    

SELECT
	product_by_ca,
    ROUND(AVG(CASE WHEN year = '2020' AND product_by_ge ='Men' THEN operating_margin END),2) AS 2020_men_profit,
	ROUND(AVG(CASE WHEN year = '2020' AND product_by_ge ='Women' THEN operating_margin END),2) AS 2020_women_profit,
    ROUND(AVG(CASE WHEN year = '2021' AND product_by_ge ='Men' THEN operating_margin END),2) AS 2021_men_profit,
    ROUND(AVG(CASE WHEN year = '2021' AND product_by_ge ='Women' THEN operating_margin END),2) AS 2021_women_profit
FROM
	(
    SELECT 
		CASE
			WHEN product LIKE "%Apparel" THEN "Apparel" 
            WHEN product LIKE "%Footwear" THEN "Footwear"
            END AS product_by_ca,
        CASE
			WHEN product LIKE "Men%" THEN "Men" 
            WHEN product LIKE "Women%" THEN "Women"
            END AS product_by_ge,
		YEAR(invoice_date) AS year,
        operating_margin
      FROM sales_data_1
      ) AS category
GROUP BY  product_by_ca;     

-- Are there any interesting patterns as to when customers buy more products in terms of seasonality?
SELECT
	YEAR(invoice_date) AS year,
    sales_method,
    SUM(CASE WHEN MONTH(invoice_date) IN (3,4,5) THEN units_sold END) AS spring,
    SUM(CASE WHEN MONTH(invoice_date) IN (6,7,8) THEN units_sold END) AS summer,
    SUM(CASE WHEN MONTH(invoice_date) IN (9,10,11) THEN units_sold END) AS autumn,
    SUM(CASE WHEN MONTH(invoice_date) IN (12,1,2) THEN units_sold END) AS winter
FROM sales_data
GROUP BY
	year, sales_method
ORDER BY year;    

-- Which retailers have the most sales per state?
WITH retailer_sales AS 
	(
	SELECT     
		state,
		retailer,
		SUM(total_sales) AS sum_sales
	FROM sales_data_1
	GROUP BY state, retailer
	),
ranked_retailer AS
	( 
    SELECT
		state,
        retailer,
        sum_sales,
		DENSE_RANK() OVER(PARTITION BY state ORDER BY sum_sales DESC) AS rank_sales
    FROM retailer_sales
    ) 
SELECT
		state,
        retailer,
        sum_sales
FROM ranked_retailer
WHERE rank_sales = 1;  