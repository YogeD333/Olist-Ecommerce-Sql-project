drop database olist_ecommerce;
CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

CREATE TABLE customers (
    customer_id VARCHAR(100) PRIMARY KEY,
    customer_unique_id VARCHAR(100),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10));

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
    
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id));

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100));

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10));

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id));
    
CREATE TABLE order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id));
    
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100));

SET SQL_SAFE_UPDATES = 0;

-- customers Table

-- Check for Missing Data

SELECT * FROM customers
WHERE customer_city IS NULL OR customer_state IS NULL;

-- Set missing city and state to 'Unknown'

UPDATE customers
SET customer_city = 'Unknown', customer_state = 'Unknown'
WHERE customer_city IS NULL OR customer_state IS NULL;

-- Remove Duplicates

DELETE FROM customers
WHERE customer_id NOT IN (
    SELECT * FROM (
        SELECT MIN(customer_id)
        FROM customers
        GROUP BY customer_unique_id
    ) AS keep_ids
)
AND customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);



-- Fix Inconsistent Values

UPDATE customers
SET customer_city = UPPER(customer_city),
    customer_state = UPPER(customer_state)
WHERE customer_city IS NOT NULL AND customer_state IS NOT NULL;

-- orders Table

-- Check for Missing Data

SELECT * FROM orders
WHERE order_status IS NULL OR order_purchase_timestamp IS NULL;

-- Update Missing Values

UPDATE orders
SET order_status = 'Pending'
WHERE order_status IS NULL;

-- Remove Orders with Invalid Dates

DELETE FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Remove Duplicate Orders

DELETE FROM orders
WHERE order_id NOT IN (
    SELECT * FROM (
        SELECT MIN(order_id)
        FROM orders
        GROUP BY customer_id, order_purchase_timestamp
    ) AS temp_orders
);


-- Standardize Date Format

UPDATE orders
SET order_purchase_timestamp = STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
WHERE order_purchase_timestamp IS NOT NULL;

-- order_items Table

-- Check for Missing Data

SELECT * FROM order_items
WHERE product_id IS NULL OR price IS NULL;

-- Update Missing Value

UPDATE order_items
SET product_id = 'Unknown', price = 0.00
WHERE product_id IS NULL OR price IS NULL;

-- Remove Duplicate Items in Orders

DELETE FROM order_items
WHERE (order_id, order_item_id) NOT IN (
    SELECT * FROM (
        SELECT MIN(order_id), MIN(order_item_id)
        FROM order_items
        GROUP BY order_id, order_item_id
    ) AS temp);
    
-- Fix Negative Prices

UPDATE order_items
SET price = 0.00
WHERE price < 0;

-- products Table

-- Check for Missing Data

SELECT * FROM products
WHERE product_category_name IS NULL;

-- Update Missing Values

UPDATE products
SET product_category_name = 'Unknown'
WHERE product_category_name IS NULL;

-- Fix Inconsistent Product Category Name

UPDATE products
SET product_category_name = TRIM(UPPER(product_category_name))
WHERE product_category_name IS NOT NULL;

-- sellers Table

-- Check for Missing Data

SELECT * FROM sellers
WHERE seller_city IS NULL OR seller_state IS NULL;

-- Update Missing Values

UPDATE sellers
SET seller_city = 'Unknown', seller_state = 'Unknown'
WHERE seller_city IS NULL OR seller_state IS NULL;

-- Fix Inconsistent Seller City and State

UPDATE sellers
SET seller_city = UPPER(seller_city),
    seller_state = UPPER(seller_state)
WHERE seller_city IS NOT NULL AND seller_state IS NOT NULL;

-- order_payments Table

-- Check for Missing Data

SELECT * FROM order_payments
WHERE payment_type IS NULL OR payment_value IS NULL;

--  Update Missing Values

UPDATE order_payments
SET payment_type = 'Unknown', payment_value = 0.00
WHERE payment_type IS NULL OR payment_value IS NULL;

-- Fix Negative Payment Values

UPDATE order_payments
SET payment_value = 0.00
WHERE payment_value < 0;

-- order_reviews Table

-- Check for Missing Data

SELECT * FROM order_reviews
WHERE review_score IS NULL;

-- Update Missing Values
 
UPDATE order_reviews
SET review_score = 0
WHERE review_score IS NULL;

-- Fix Invalid Review Scores

UPDATE order_reviews
SET review_score = 0
WHERE review_score < 1 OR review_score > 5;

-- product_category_name_translation Table

-- Check for Missing Data

SELECT * FROM product_category_name_translation
WHERE product_category_name_english IS NULL;

-- Update Missing Values

UPDATE product_category_name_translation
SET product_category_name_english = 'Unknown'
WHERE product_category_name_english IS NULL;

-- Data Integrity Checks

-- Check customer_id in orders

SELECT order_id
FROM orders
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

-- Check order_id in order_items

SELECT order_id
FROM order_items
WHERE order_id NOT IN (SELECT order_id FROM orders);

-- Check product_id in order_items
 
SELECT product_id
FROM order_items
WHERE product_id NOT IN (SELECT product_id FROM products);


-- Check order_id in order_payments

SELECT order_id
FROM order_payments
WHERE order_id NOT IN (SELECT order_id FROM orders);

-- Check order_id in order_reviews

SELECT order_id
FROM order_reviews
WHERE order_id NOT IN (SELECT order_id FROM orders);

-- Creating Indexes

CREATE INDEX idx_customer_id ON customers(customer_id);
CREATE INDEX idx_order_id ON orders(order_id);
CREATE INDEX idx_product_id ON order_items(product_id);
CREATE INDEX idx_seller_id ON sellers(seller_id);
CREATE INDEX idx_payment_id ON order_payments(order_id, payment_sequential);
CREATE INDEX idx_review_id ON order_reviews(review_id);

-- checking index

SHOW INDEX FROM order_items;
SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM sellers;
SHOW INDEX FROM order_payments;
SHOW INDEX FROM order_reviews;

-- Count total customers

SELECT COUNT(*) AS total_customers 
FROM customers;

-- Number of orders placed

SELECT COUNT(*) AS total_orders 
FROM orders;

-- Order status distribution

SELECT order_status, COUNT(*) AS status_count
FROM orders
GROUP BY order_status;

-- Top cities by number of customers

SELECT customer_city, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;
 
-- Top product categories

SELECT product_category_name, COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count DESC
LIMIT 10;

-- Total revenue per day

SELECT DATE(order_purchase_timestamp) AS order_date,
       SUM(price)AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_date
ORDER BY order_date;

-- Top 5 revenue-generating cities

SELECT c.customer_city, ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_city
ORDER BY revenue DESC
LIMIT 5;

-- Average delivery delay (in days)

SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)), 2) AS avg_delay
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Most common payment types

SELECT payment_type, COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- Average review score

SELECT ROUND(AVG(review_score), 2) AS avg_score
FROM order_reviews;

-- Top 10 product categories by revenue**

SELECT p.product_category_name, ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Repeat customers (placed more than 1 order)

SELECT customer_unique_id, COUNT(*) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING order_count > 1
ORDER BY order_count DESC;

-- Revenue generated by each seller

SELECT s.seller_id, ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_id
ORDER BY total_sales DESC
LIMIT 10;

-- Product category with best customer reviews

SELECT p.product_category_name, ROUND(AVG(r.review_score), 2) AS avg_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING COUNT(r.review_score) > 50
ORDER BY avg_score DESC
LIMIT 10;

-- First order date for each customer

SELECT customer_id, order_id, order_purchase_timestamp
FROM (
  SELECT customer_id, order_id, order_purchase_timestamp,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS rn
  FROM orders
) AS ranked_orders
WHERE rn = 1;

-- Monthly revenue trend

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
       ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Order-to-delivery time per order

SELECT order_id,
       DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Most refunded products (low review scores)

SELECT p.product_category_name, COUNT(*) AS bad_reviews
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE r.review_score <= 2
GROUP BY p.product_category_name
ORDER BY bad_reviews DESC
LIMIT 10;

-- CTE: Revenue per category with ranking**

WITH category_revenue AS (
  SELECT p.product_category_name, ROUND(SUM(oi.price), 2) AS revenue
  FROM products p
  JOIN order_items oi ON p.product_id = oi.product_id
  GROUP BY p.product_category_name
)
SELECT *, RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM category_revenue;

-- Best performing sellers by monthly sales

SELECT seller_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
       ROUND(SUM(oi.price), 2) AS monthly_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY seller_id, month
ORDER BY monthly_sales DESC;


















