-- ================================================
-- Superstore Sales Analysis
-- Goal: Profitability, loss products, discount strategy
-- Date: 30.04.2026
-- ================================================

SELECT * FROM superstore LIMIT 5;

-- How much profit did the Superstore generate in total?
SELECT ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore AS s;

-- Total profit across all years: 286,397$

-- Which product category generates the most profit?
SELECT category, ROUND(SUM(profit)::numeric, 2) AS revenue_category
FROM superstore s
GROUP BY category
ORDER BY revenue_category DESC;

-- Technology generates the highest profit. Furniture is significantly lower than Technology.

-- Which region generates the most profit?
SELECT region, ROUND(SUM(profit)::numeric, 2) AS revenue_region
FROM superstore s
GROUP BY region
ORDER BY revenue_region DESC;

-- The West region generates the highest profit, followed by the East.

-- Furniture has almost 8x less profit than Technology — even though Furniture items are often more expensive. Why?
SELECT category,
       ROUND(SUM(sales)::numeric, 2) AS total_sales,
       ROUND(SUM(profit)::numeric, 2) AS total_profit,
       ROUND(AVG(discount)::numeric, 2) AS avg_discount
FROM superstore s
GROUP BY category
ORDER BY total_sales DESC;

-- Furniture revenue is high but profit is very low. Likely caused by high purchase costs or insufficient pricing.

-- What is the profit margin per category?
SELECT category, ROUND((SUM(profit)/SUM(sales))::numeric, 2)*100 AS "margin in %"
FROM superstore s
GROUP BY category;

-- With a margin of only 2%, the Furniture category is critically underperforming.

-- Which products generate a loss?
SELECT product_name, ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM superstore s
GROUP BY product_name
HAVING ROUND(SUM(s.profit)::numeric, 2) < 0
ORDER BY total_profit
    LIMIT 10;

-- Losses are concentrated in expensive electronics and large furniture items.

-- Which customers generate an overall loss for the Superstore?
SELECT s.customer_name, ROUND(SUM(profit)::numeric, 2) AS total_loss
FROM superstore s
GROUP BY s.customer_name
HAVING ROUND(SUM(profit)::numeric, 2) < 0
ORDER BY total_loss ASC
    LIMIT 10;

-- The largest losses were caused by Cindy Stewart. Why?

-- What did Cindy Stewart buy? Products, revenue, and profit breakdown.
SELECT s.customer_name, s.product_name, s.sales, s.profit, s.discount*100 AS "discount in %", s.quantity
FROM superstore s
WHERE s.customer_name = 'Cindy Stewart'
ORDER BY s.profit ASC;

-- Two large, expensive orders were sold with a 70% discount, resulting in an enormous loss.

-- Is there a correlation between discount level and profit? At what point does it become dangerous?
SELECT s.discount * 100 AS "discount in %", ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM superstore s
GROUP BY s.discount
ORDER BY "discount in %" DESC;

-- Profits turn negative at discounts above 30% -> No discount above 20% recommended.


-- ================================================
-- JOIN ANALYSIS: Customer Segments
-- ================================================

-- Table 1: Customers
CREATE TABLE customers AS
SELECT DISTINCT customer_id, customer_name, segment, region
FROM superstore;

-- Table 2: Orders
CREATE TABLE orders AS
SELECT order_id, customer_id, sales, profit, category, order_date
FROM superstore;

-- All orders with corresponding customer name and segment
SELECT c.customer_name, c.segment, o.order_id, o.sales, o.profit
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
    LIMIT 5;

-- Which segment (Consumer, Corporate, Home Office) is the most profitable?
SELECT c.segment, ROUND(SUM(o.profit)::numeric, 2) AS total_profit
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY total_profit DESC;

-- Consumer segment generates the highest total profit. Is this due to volume?

-- How many customers and orders does each segment have?
SELECT c.segment, COUNT(DISTINCT c.customer_id) AS total_customers, COUNT(o.order_id) AS total_orders
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.segment;

-- Consumer segment has 409 customers and 17,539 orders — pure volume explains the higher total profit.

-- What is the average profit per customer by segment?
SELECT c.segment, COUNT(DISTINCT c.customer_id) AS customers, ROUND(SUM(o.profit)::numeric, 2) AS total_profit,
       ROUND((SUM(o.profit))/(COUNT(DISTINCT c.customer_id))::numeric, 2) AS profit_per_customer
FROM customers c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.segment
ORDER BY profit_per_customer DESC;

-- Corporate customers are the most profitable per capita, closely followed by Home Office.
-- Recommendation: Prioritize Corporate and Home Office acquisition. Keep Consumer segment stable.


-- ================================================
-- TIME ANALYSIS
-- ================================================

-- How has revenue developed year over year?
SELECT EXTRACT(YEAR FROM s.order_date) AS year, ROUND(SUM(s.sales)::numeric, 2) AS total_sales
FROM superstore s
GROUP BY EXTRACT(YEAR FROM s.order_date)
ORDER BY year;

-- Annual growth is visible, except from 2014 to 2015 where a decline occurred.

-- What happened in 2015? Which category lost the most?
SELECT EXTRACT(YEAR FROM s.order_date) AS year, s.category, ROUND(SUM(s.sales)::numeric, 2) AS total_sales
FROM superstore s
WHERE EXTRACT(YEAR FROM s.order_date) IN (2014, 2015)
GROUP BY s.category, EXTRACT(YEAR FROM s.order_date)
ORDER BY s.category;

-- Category comparison 2014 vs 2015 with difference
SELECT
    a.category,
    a.total_sales AS sales_2014,
    b.total_sales AS sales_2015,
    ROUND((b.total_sales - a.total_sales)::numeric, 2) AS difference
FROM
    (SELECT category, ROUND(SUM(sales)::numeric, 2) AS total_sales
     FROM superstore WHERE EXTRACT(YEAR FROM order_date) = 2014
     GROUP BY category) a
        JOIN
    (SELECT category, ROUND(SUM(sales)::numeric, 2) AS total_sales
     FROM superstore WHERE EXTRACT(YEAR FROM order_date) = 2015
     GROUP BY category) b
    ON a.category = b.category
ORDER BY difference;

-- Office Supplies and Technology experienced a revenue decline. Possible causes: new competition or reduced marketing spend.
-- Furniture grew despite structurally poor margins.

-- Which month is generally the strongest?
SELECT EXTRACT(MONTH FROM s.order_date) AS month, ROUND(SUM(s.sales)::numeric, 2) AS total_earnings, ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM superstore s
GROUP BY EXTRACT(MONTH FROM s.order_date)
ORDER BY total_earnings DESC;

-- November and December are the strongest months by revenue — likely driven by holiday season.
-- Profit is higher in December despite lower revenue than November.

-- What is the average discount in November vs December?
SELECT EXTRACT(MONTH FROM s.order_date) AS month, ROUND(AVG(s.discount)::numeric, 2)*100 AS discount
FROM superstore s
WHERE EXTRACT(MONTH FROM s.order_date) IN (11, 12)
GROUP BY month;

-- November discounts are only 1% higher. The lower margin must have a different cause.

-- Which categories are purchased in November vs December?
SELECT EXTRACT(MONTH FROM s.order_date) AS month, s.category, ROUND(SUM(s.sales)::numeric, 2) AS total_earnings, ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM superstore s
WHERE EXTRACT(MONTH FROM s.order_date) IN (11, 12)
GROUP BY s.category, month;

-- November shows significantly higher Technology revenue but at a lower margin.
-- Furniture shows similar revenue in both months but with strongly varying profit.


-- ================================================
-- TOP CUSTOMERS & LOGISTICS
-- ================================================

-- Which 10 customers are the most valuable for the Superstore?
SELECT s.customer_id, s.customer_name AS customer, ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM superstore s
GROUP BY s.customer_id, s.customer_name
ORDER BY total_profit DESC
    LIMIT 10;

-- What is the average shipping duration per ship mode?
SELECT s.ship_mode, ROUND(AVG(s.ship_date - s.order_date)::numeric, 2) AS delivery_time
FROM superstore s
GROUP BY s.ship_mode
ORDER BY delivery_time DESC;

-- Standard Class shipping averages 5 days — completely acceptable.
-- Same Day delivery is processed in 0.04 days — nearly instant.