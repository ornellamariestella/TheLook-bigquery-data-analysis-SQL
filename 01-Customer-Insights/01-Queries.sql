-- 1. Where do our customers come from? Which are the most active countries in terms of purchases?

WITH customer_base AS 
(
    SELECT
        users.id AS customer,
        SUM(CASE WHEN users.gender = 'F' THEN 1 ELSE NULL END) AS female,
        SUM(CASE WHEN users.gender = 'M' THEN 1 ELSE NULL END) AS male,
        users.country AS country,
        order_id
    FROM `bigquery-public-data.thelook_ecommerce.orders` AS orders
    LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
    ON orders.user_id = users.id
    GROUP BY 
    customer, country, orders.order_id
)

SELECT
    country,
    COUNT(DISTINCT customer) AS nr_customers,
    COUNT(female) AS females,
    COUNT(male) AS males,
    COUNT(DISTINCT order_id) AS nr_orders -- I also want to display the total orders by country
    FROM  customer_base
FROM customer_base
GROUP BY 
country
ORDER BY 
nr_customers DESC

-- 2. What is our gender segmentation?

SELECT
    users.gender,
    COUNT(DISTINCT orders.order_id) AS cnt_orders
FROM `bigquery-public-data.thelook_ecommerce.orders` AS orders
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
ON orders.user_id = users.id
GROUP BY 
users.gender
ORDER BY 
cnt_orders DESC

-- 3. What is our age segmentation?
-- First, I will create a pivot table to filter age groups, then I will need to calculate the %

WITH age_groups AS 
(
    SELECT
        SUM(CASE WHEN age < 20 THEN 1 ELSE 0 END) AS under20,
        SUM(CASE WHEN age BETWEEN 20 AND 39 THEN 1 ELSE 0 END) AS age20_39,
        SUM(CASE WHEN age BETWEEN 40 AND 59 THEN 1 ELSE 0 END) AS age40_59,
        SUM(CASE WHEN age BETWEEN 60 AND 79 THEN 1 ELSE 0 END) AS age60_79,
        SUM(CASE WHEN age >= 80 THEN 1 ELSE 0 END) AS over80,
        COUNT(DISTINCT id) AS total_users
    FROM `bigquery-public-data.thelook_ecommerce.users`
)

SELECT
    ROUND(under20 / total_users * 100, 2) AS under20_perc,
    ROUND(age20_39 / total_users * 100, 2) AS age20_39_perc,
    ROUND(age40_59 / total_users * 100, 2) AS age40_59_perc,
    ROUND(age60_79 / total_users * 100, 2) AS age60_79_perc,
    ROUND(over80 / total_users * 100, 2) AS over80_perc
FROM age_groups

-- 4. Who are our most loyal customers?
-- I decided to provide a list of our top 5 customers

SELECT
    CONCAT(b.first_name, ' ', b.last_name) AS full_name, -- I want to create a single column joining first and last names
    STRING_AGG(DISTINCT b.email, ', ') AS email_address, -- I want to avoid repeting the same email address
    COUNT(DISTINCT a.order_id) AS cnt_orders
FROM `bigquery-public-data.thelook_ecommerce.orders` a
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` b
ON a.user_id = b.id
GROUP BY 
full_name
ORDER BY 
cnt_orders DESC
LIMIT 5