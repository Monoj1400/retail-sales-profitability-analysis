USE retail_analysis;
CREATE TABLE IF NOT exists orders (
    `Row ID` INT,
    `Order ID` VARCHAR(30),
    `Order Date` VARCHAR(20),
    `Ship Date` VARCHAR(20),
    `Ship Mode` VARCHAR(30),
    `Customer ID` VARCHAR(20),
    `Customer Name` VARCHAR(100),
    `Segment` VARCHAR(30),
    `Country/Region` VARCHAR(50),
    `City` VARCHAR(100),
    `State/Province` VARCHAR(100),
    `Postal Code` VARCHAR(20),
    `Region` VARCHAR(30),
    `Product ID` VARCHAR(30),
    `Category` VARCHAR(50),
    `Sub-Category` VARCHAR(50),
    `Product Name` VARCHAR(255),
    `Sales` DECIMAL(12,4),
    `Quantity` INT,
    `Discount` DECIMAL(6,4),
    `Profit` DECIMAL(12,4)
);

LOAD DATA LOCAL INFILE 'C:/Retail_Sales_Analysis/data/orders_import.csv'
INTO TABLE orders
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    `Row ID`,
    `Order ID`,
    `Order Date`,
    `Ship Date`,
    `Ship Mode`,
    `Customer ID`,
    `Customer Name`,
    `Segment`,
    `Country/Region`,
    `City`,
    `State/Province`,
    `Postal Code`,
    `Region`,
    `Product ID`,
    `Category`,
    `Sub-Category`,
    `Product Name`,
    `Sales`,
    `Quantity`,
    `Discount`,
    `Profit`
);

SELECT COUNT(*) AS total_records FROM orders;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Row ID`) AS unique_row_ids
FROM orders;

SELECT
    `Order ID`,
    `Order Date`,
    `Ship Date`,
    `Product Name`,
    Sales,
    Quantity,
    Discount,
    Profit
FROM orders
LIMIT 10;

SELECT
    SUM(`Order ID` IS NULL) AS missing_order_ids,
    SUM(`Order Date` IS NULL) AS missing_order_dates,
    SUM(Sales IS NULL) AS missing_sales,
    SUM(Profit IS NULL) AS missing_profit
FROM orders;

SELECT
    `Order Date`,
    STR_TO_DATE(`Order Date`, '%c/%e/%Y') AS parsed_order_date,
    `Ship Date`,
    STR_TO_DATE(`Ship Date`, '%c/%e/%Y') AS parsed_ship_date
FROM orders
LIMIT 10;

SELECT
    COUNT(*) AS total_rows,
    SUM(STR_TO_DATE(`Order Date`, '%c/%e/%Y') IS NULL)
        AS invalid_order_dates,
    SUM(STR_TO_DATE(`Ship Date`, '%c/%e/%Y') IS NULL)
        AS invalid_ship_dates,
    MIN(STR_TO_DATE(`Order Date`, '%c/%e/%Y'))
        AS first_order_date,
    MAX(STR_TO_DATE(`Order Date`, '%c/%e/%Y'))
        AS last_order_date
FROM orders;


-- PROJECT: Retail Sales & Profitability Analysis
-- SECTION 1: Overall Business Performance
-- PURPOSE:
-- Calculate the main business KPIs for the entire dataset.
-- These values will later be used in the Power BI dashboard.
-- Profit margin measures profit earned per dollar of sales.

USE retail_analysis;

SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS total_units_sold,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders;



-- SECTION 2: Product Category Performance
-- PURPOSE:
-- Compare sales, profit, units sold, and profit margin
-- across product categories.
-- This helps identify the categories contributing most
-- to overall business performance.

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS units_sold,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY Category
ORDER BY total_profit DESC;


-- SECTION 3: Subcategory Profitability
-- PURPOSE:
-- Break down performance into individual product subcategories.
-- Sorting by profit from lowest to highest reveals
-- which subcategories may be losing money.

SELECT
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS units_sold,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY Category, `Sub-Category`
ORDER BY total_profit ASC;


-- SECTION 4: Discount and Profitability Analysis
-- PURPOSE:
-- Compare average discounts and total profit by subcategory.
-- This helps identify whether loss-making subcategories
-- are associated with higher discounting.
-- Note: association alone does not prove that discounts
-- caused the losses.

SELECT
    Category,
    `Sub-Category`,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY Category, `Sub-Category`
ORDER BY total_profit ASC;


-- SECTION 5: Profitability by Discount Band
-- PURPOSE:
-- Group records into discount ranges and compare sales,
-- profit, and profit margin for each range.
-- This helps investigate the relationship between discounts
-- and profitability. It does not establish causation.

SELECT
    CASE
        WHEN Discount = 0 THEN '0% discount'
        WHEN Discount <= 0.10 THEN '1–10% discount'
        WHEN Discount <= 0.20 THEN '11–20% discount'
        WHEN Discount <= 0.30 THEN '21–30% discount'
        ELSE 'Above 30% discount'
    END AS discount_band,

    COUNT(*) AS line_items,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM orders
GROUP BY discount_band
ORDER BY MIN(Discount);


-- SECTION 6: Data Integrity and Duplicate Import Check
-- PURPOSE:
-- Confirm the current row count and number of unique Row IDs.
-- The original dataset contained 10,194 records.
-- If the table has more rows than unique Row IDs, some records
-- may have been imported more than once.

SELECT
    COUNT(*) AS current_row_count,
    COUNT(DISTINCT `Row ID`) AS unique_row_ids,
    COUNT(*) - COUNT(DISTINCT `Row ID`) AS possible_duplicate_rows,
    ROUND(SUM(Sales), 2) AS current_total_sales,
    ROUND(SUM(Profit), 2) AS current_total_profit
FROM orders;


-- SECTION 7: Validate Discount-Band Counts
-- PURPOSE:
-- Recalculate the number of records in each discount band.
-- The sum of these counts should equal the total number
-- of rows in the orders table: 10,194.

SELECT
    CASE
        WHEN Discount = 0 THEN '0% discount'
        WHEN Discount <= 0.10 THEN '1–10% discount'
        WHEN Discount <= 0.20 THEN '11–20% discount'
        WHEN Discount <= 0.30 THEN '21–30% discount'
        ELSE 'Above 30% discount'
    END AS discount_band,
    COUNT(*) AS line_items,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY discount_band
ORDER BY MIN(Discount);



-- SECTION 8: Verify Overall Totals
-- PURPOSE:
-- Recalculate sales and profit directly from the orders table.
-- These totals should match the sum of sales and profit
-- across all discount bands.

SELECT
    COUNT(*) AS total_rows,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    MIN(Discount) AS minimum_discount,
    MAX(Discount) AS maximum_discount
FROM orders;


-- SECTION 9: Profitability by Discount Band
-- PURPOSE:
-- Calculate the profit margin directly from total profit
-- and total sales for each discount band.
-- This helps identify the discount ranges associated
-- with positive and negative profitability.

SELECT
    CASE
        WHEN Discount = 0 THEN '0% discount'
        WHEN Discount <= 0.10 THEN '1–10% discount'
        WHEN Discount <= 0.20 THEN '11–20% discount'
        WHEN Discount <= 0.30 THEN '21–30% discount'
        ELSE 'Above 30% discount'
    END AS discount_band,
    COUNT(*) AS line_items,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY discount_band
ORDER BY MIN(Discount);



-- SECTION 10: Identify the 10 Most Loss-Making Products
-- PURPOSE:
-- Find individual products with the largest total losses.
-- This helps the business prioritize products for pricing,
-- discount, and cost-structure reviews.

SELECT
    `Product ID`,
    `Product Name`,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM orders
GROUP BY
    `Product ID`,
    `Product Name`,
    Category,
    `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC
LIMIT 10;


-- SECTION 11: Transaction-Level Loss Analysis
-- PURPOSE:
-- Examine individual product-line records for the 3D printers
-- with the largest losses.
-- Compare discounts, sales, quantities, and profit to identify
-- whether losses are concentrated in particular transactions.

SELECT
    `Order ID`,
    `Order Date`,
    `Product Name`,
    Sales,
    Quantity,
    Discount,
    Profit
FROM orders
WHERE `Product Name` LIKE '%Cubify CubeX 3D Printer%'
ORDER BY Profit ASC
LIMIT 20;


-- SECTION 12: Cubify Printer Profitability by Discount
-- PURPOSE:
-- Compare sales, profit, and units sold at each discount level
-- for Cubify CubeX 3D printers.
-- This helps determine whether high-discount transactions
-- consistently coincide with losses.

SELECT
    `Product Name`,
    Discount,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE `Product Name` LIKE '%Cubify CubeX 3D Printer%'
GROUP BY `Product Name`, Discount
ORDER BY `Product Name`, Discount;


-- SECTION 13: High-Discount Loss Analysis
-- PURPOSE:
-- Measure total sales and profit for transactions with discounts
-- above 30%, grouped by category and subcategory.
-- This identifies where high-discount losses are concentrated.

SELECT
    Category,
    `Sub-Category`,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Discount > 0.30
GROUP BY Category, `Sub-Category`
ORDER BY total_profit ASC;


-- SECTION 14: Loss-Making Binder Products
-- PURPOSE:
-- Identify the Binders products with the largest losses
-- among transactions with discounts above 30%.
-- This helps prioritize specific products for pricing review.

SELECT
    `Product ID`,
    `Product Name`,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM orders
WHERE Category = 'Office Supplies'
  AND `Sub-Category` = 'Binders'
  AND Discount > 0.30
GROUP BY
    `Product ID`,
    `Product Name`
ORDER BY total_profit ASC
LIMIT 10;



-- SECTION 15: Binder Product Profitability at All Discount Levels
-- PURPOSE:
-- Analyze the three most loss-making binder products
-- across every discount level.
-- This helps determine whether losses are concentrated
-- in high-discount transactions or occur more broadly.

SELECT
    `Product Name`,
    Discount,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE `Product ID` IN (
    'OFF-BI-10004995',
    'OFF-BI-10005425',
    'OFF-BI-10001359'
)
GROUP BY
    `Product Name`,
    Discount
ORDER BY
    `Product Name`,
    Discount;


-- SECTION 16: Overall Performance of Selected Binder Products
-- PURPOSE:
-- Compare total sales, total profit, units sold, and profit margin
-- for the three selected binding-system products.
-- This establishes an overall baseline before recommending
-- changes to discounting practices.

SELECT
    `Product ID`,
    `Product Name`,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE `Product ID` IN (
    'OFF-BI-10004995',
    'OFF-BI-10005425',
    'OFF-BI-10001359'
)
GROUP BY
    `Product ID`,
    `Product Name`
ORDER BY total_profit ASC;


-- SECTION 17: Regional Sales and Profitability
-- PURPOSE:
-- Compare sales, profit, order volume, and profit margin
-- across the business regions.
-- This identifies strong markets and regions that may
-- need further investigation.

SELECT
    Region,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY Region
ORDER BY total_profit DESC;



-- SECTION 18: Category Performance by Region
-- PURPOSE:
-- Compare sales, profit, and profit margin for each category
-- within every region.
-- This helps identify which product categories contribute
-- to the profitability gap between regions.

SELECT
    Region,
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
GROUP BY Region, Category
ORDER BY Region, total_profit DESC;


-- SECTION 19: Furniture Subcategory Performance by Region
-- PURPOSE:
-- Compare sales and profitability for each Furniture
-- subcategory across regions.
-- This identifies which subcategories contribute most
-- to regional Furniture losses.

SELECT
    Region,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Category = 'Furniture'
GROUP BY Region, `Sub-Category`
ORDER BY Region, total_profit ASC;


-- SECTION 20: Central Furniture Profitability by Discount
-- PURPOSE:
-- Compare sales and profit at each discount level for
-- Furniture subcategories in the Central region.
-- This helps identify discount ranges associated with losses.

SELECT
    `Sub-Category`,
    Discount,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Region = 'Central'
  AND Category = 'Furniture'
GROUP BY
    `Sub-Category`,
    Discount
ORDER BY
    `Sub-Category`,
    Discount;


-- SECTION 21: Central Furniture Losses at Discounts Above 20%
-- PURPOSE:
-- Calculate total sales, profit, and margin for Central Furniture
-- transactions with discounts greater than 20%.
-- This quantifies the financial impact of these transactions
-- and helps prioritize further investigation.

SELECT
    `Sub-Category`,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Region = 'Central'
  AND Category = 'Furniture'
  AND Discount > 0.20
GROUP BY `Sub-Category`
ORDER BY total_profit ASC;


-- SECTION 22: High-Discount Furniture Performance by Region
-- PURPOSE:
-- Compare Furniture profitability across regions for
-- transactions with discounts greater than 20%.
-- This helps determine whether high-discount losses are
-- concentrated in Central or occur across the business.

SELECT
    Region,
    COUNT(*) AS transaction_lines,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Category = 'Furniture'
  AND Discount > 0.20
GROUP BY Region
ORDER BY total_profit ASC;


-- SECTION 23: Furniture Profitability by Discount Group
-- PURPOSE:
-- Compare Furniture transactions with discounts of 20% or less
-- against transactions with discounts above 20%.
-- This quantifies the association between discount groups
-- and profitability across the whole business.

SELECT
    CASE
        WHEN Discount <= 0.20 THEN '20% discount or less'
        ELSE 'Above 20% discount'
    END AS discount_group,
    COUNT(*) AS transaction_lines,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100 * SUM(Profit) / NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct
FROM orders
WHERE Category = 'Furniture'
GROUP BY discount_group
ORDER BY MIN(Discount);


-- SECTION 24: Business Finding - Furniture Discount Analysis
-- FINDING:
-- Furniture transactions with discounts of 20% or less
-- generated $74,686.28 profit at a 13.38% margin.
-- Transactions with discounts above 20% generated a loss
-- of $54,956.29 at a -27.98% margin.
--
-- RECOMMENDATION:
-- Review high-discount Furniture transactions, especially
-- those in the Central and East regions.
-- Investigate product-level costs and margins before
-- establishing discount limits.
--
-- LIMITATION:
-- These results show an association, not proof that discounts
-- alone caused the losses. A discount cap should be tested
-- against product-level profitability before implementation.

