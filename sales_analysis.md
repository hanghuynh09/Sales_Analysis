### SALES ANALYSIS
```sql

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
```
 ##### DATA OBSERVATION

Number of rows in dataset
```sql
SELECT COUNT(*) AS total_rows
FROM sales_data;
```
<img src="./Code Snapshot/total_rows_1.png" alt="Getting started" width="100" />

Number of Retailers  
```sql
SELECT 
	DISTINCT retailer
FROM sales_data;
```
<img src="./Code Snapshot/retailer.png" alt="Getting started" width="100" />

Number of Sales Method
```sql
SELECT sales_method, COUNT(*) AS no_of_sales_method
FROM sales_data
GROUP BY sales_method;
```
<img src="./Code Snapshot/Sales Method.png" alt="Getting started" width="100" />

Number of Product
```sql
SELECT product, COUNT(*) AS no_of_product
FROM sales_data
GROUP BY product;
```
<img src="./Code Snapshot/Product.png" alt="Getting started" width="160" />

Number of blank and null rows

```sql
SELECT "blank_null_retailer" AS column_name, COUNT(*) AS value_count FROM sales_data WHERE sales_data.retailer IS NULL OR sales_data.retailer = ''
UNION ALL
SELECT "blank_null_retailer_id" , COUNT(*) FROM sales_data WHERE sales_data.retailer_id IS NULL OR sales_data.retailer_id = ''
UNION ALL
SELECT "blank_null_invoice_date" , COUNT(*) FROM sales_data WHERE sales_data.invoice_date IS NULL 
UNION ALL
SELECT "blank_null_region" , COUNT(*) FROM sales_data WHERE sales_data.region IS NULL OR sales_data.region = ''
UNION ALL
SELECT "blank_null_state" , COUNT(*) FROM sales_data WHERE sales_data.state IS NULL OR sales_data.state = ''
UNION ALL
SELECT "blank_null_city" , COUNT(*) FROM sales_data WHERE sales_data.city IS NULL OR sales_data.city = ''
UNION ALL
SELECT "blank_null_product" , COUNT(*) FROM sales_data WHERE sales_data.product IS NULL OR sales_data.product = ''
UNION ALL
SELECT "blank_null_price_per_unit" , COUNT(*) FROM sales_data WHERE sales_data.price_per_unit IS NULL OR sales_data.price_per_unit = ''
UNION ALL
SELECT "blank_null_units_sold" , COUNT(*) FROM sales_data WHERE sales_data.units_sold IS NULL OR sales_data.units_sold = ''
UNION ALL
SELECT "blank_null_total_sales" , COUNT(*) FROM sales_data WHERE sales_data.total_sales IS NULL OR sales_data.total_sales = ''
UNION ALL
SELECT "blank_null_operating_profit" , COUNT(*) FROM sales_data WHERE sales_data.operating_profit IS NULL OR sales_data.operating_profit=''
UNION ALL
SELECT "blank_null_operating_margin" , COUNT(*) FROM sales_data WHERE sales_data.operating_margin IS NULL OR sales_data.operating_margin = ''
UNION ALL
SELECT "blank_null_sales_method" , COUNT(*) FROM sales_data WHERE sales_data.sales_method IS NULL OR sales_data.operating_margin = '';
```
<img src="./Code Snapshot/blank_null.png" width="220" />

Number of Duplicated Rows
```sql
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
```
<img src="./Code Snapshot/duplicate_rows.png" width="130" />

##### DATA CLEANING
```sql
-- creating a backup table
CREATE TABLE sales_data_1 AS
SELECT * FROM sales_data;

-- deleting blank values
DELETE FROM sales_data_1
WHERE units_sold = '';

-- removing redundant symbols in values 
UPDATE sales_data_1
SET total_sales = REPLACE(total_sales, "$","");

UPDATE sales_data_1
SET total_sales = REPLACE(total_sales, ",","");

UPDATE sales_data_1
SET operating_profit = REPLACE(operating_profit, ",","");

UPDATE sales_data_1
SET operating_margin = REPLACE(operating_margin, "%","");

```
Total Rows After Cleaning
```sql
SELECT 
    COUNT(*) AS total_rows
FROM sales_data_1;
```
<img src="./Code Snapshot/total_rows_a.png" width="100" />

#### DATA ANALYSIS

*Total Sales by Each Year:*
```sql
SELECT 
    YEAR(invoice_date) AS year, 
    SUM(total_sales) AS sum_of_sales
FROM sales_data_1
GROUP BY year;
```
<img src="./Code Snapshot/year_sales_2.png" width="150" />


*Total Sales by Years and Retailers :*
```sql
SELECT 
    retailer,
    SUM(CASE WHEN YEAR(invoice_date) = 2020 THEN total_sales ELSE 0 END) AS 2020_sales,
    SUM(CASE WHEN YEAR(invoice_date) = 2021 THEN total_sales ELSE 0 END) AS 2021_sales
FROM 
	sales_data_1
GROUP BY retailer;
```
<img src="./Code Snapshot/sales_year_retailer.png" width="220" />

*Top 5 Product by Year*
```sql
--2020
SELECT 
    product, 
    SUM(total_sales) AS sum_of_sales,
    YEAR(invoice_date) AS year
FROM 
	sales_data_1
WHERE 
	YEAR(invoice_date) = '2020'
GROUP BY product, year
ORDER BY sum_of_sales DESC
LIMIT 5;

--2021
SELECT 
    product, 
    SUM(total_sales) AS sum_of_sales,
    YEAR(invoice_date) AS Year
FROM 
	sales_data_1
WHERE 
	YEAR(invoice_date) = '2021'
GROUP BY product, Year
ORDER BY sum_of_sales DESC
LIMIT 5;
```
 <img src="./Code Snapshot/top5_1.png" width="240" />
 <img src="./Code Snapshot/top5_2.png" width="240" />

*The Top Region, State, City for Sales:*
```sql
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
CALL top_sales_by_area_and_year('city', 2020, 2021);
CALL top_sales_by_area_and_year('state', 2020, 2021);
CALL top_sales_by_area_and_year('region', 2020, 2021);
```
 <img src="./Code Snapshot/city.png" width="180" />
 <img src="./Code Snapshot/state.png" width="170" />
  <img src="./Code Snapshot/region.png" width="160" />

*Sales Methods are the Top 3 for Sales:*
```sql
SELECT 
	sales_method,
	SUM(CASE WHEN YEAR(invoice_date) = '2020' THEN total_sales ELSE 0 END) AS 2020_sales,
	SUM(CASE WHEN YEAR(invoice_date) = '2021' THEN total_sales ELSE 0 END) AS 2021_sales
FROM sales_data_1
GROUP BY sales_method;
```
<img src="./Code Snapshot/method_over_year.png" width="210" /> 

*Profit Margin for different Product Categories:*

```sql
-- profit margin over year by product caterories(apparel/footwear), gender(men/women)
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
```
<img src="./Code Snapshot/profit_ca_ge.png" width="460" />

*Units Sold in terms of Seasonality:*
```sql
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
```
<img src="./Code Snapshot/seasonality.png" width="290" />

*Retailers have the Most Sales per State:*
```sql
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
```
<img src="./Code Snapshot/state_1.png" width="200" />
<img src="./Code Snapshot/state_2.png" width="200" />
<img src="./Code Snapshot/state_3.png" width="200" />
<img src="./Code Snapshot/state_4.png" width="200" />

#### Key insights derived from Adidas Sale analysis:


- **Sales Performance Over Time**

 There is a significant increase in sales from 2020 to 2021. Sales revenue grew from 182.08M in 2020 to 717.82M in 2021, indicating robust growth.


- **Sales by Region**

*Top Regions*: The Northeast region leads in sales with 50M  , followed by the West with  35M  , and the Southeast with $29M. This highlights the Northeast as a critical market for Adidas.


- **Units Sold by Product Category**

*Product Demand*: Footwear is the most popular product category, with 0.85M units sold in 2021 compared to 0.18M in 2020. Apparel sales also saw an increase, though less pronounced, from 0.06M in 2020 to 0.35M in 2021.

*Gender Distribution*: The sales of men's footwear significantly outpace those of women's footwear in 2021, suggesting a higher demand among male consumers.


- **Sales Channels**

*Retailer Performance*: Among retailers, West Gear and Foot Locker were strong performers in 2021, with West Gear showing prominent sales in both 2020 and 2021. Foot Locker's 2021 performance also stands out.

*Sales Method*: Across different retailers, in-store sales remain dominant, though online and outlet sales also contribute significantly. This indicates a diverse sales strategy balancing brick-and-mortar and e-commerce channels.


- **Seasonal Sales Trends**

*Seasonal Variations*: Sales methods vary by season, with online sales peaking in autumn and winter, while in-store and outlet sales have a steadier distribution throughout the year. This points to seasonal preferences in shopping behavior.


- **Operating Margin**

*Margin Fluctuations*: The average operating margin shows fluctuations across quarters. Notably, there were significant increases in Q3 2020 and Q4 2021, which may correlate with strategic initiatives or market conditions favoring Adidas during these periods.


- **Total Sales by State**

*Geographical Distribution*: The analysis results indicates varied sales performance across states, with some states exhibiting higher total sales(New York in 2020 and California in 2021). This can inform regional marketing and inventory strategies to optimize sales performance.