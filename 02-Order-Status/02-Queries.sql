-- 1. How many of our orders got cancelled or returned? Is there a correlation between problematic orders and customers’ age?
-- For this analysis, I am interested in problematic statuses only (= returned and cancelled orders) and their age brackets:

SELECT CASE
    WHEN orders.status IN ('Complete', 'Shipped', 'Processing') THEN 'Unproblematic'
    ELSE orders.status
  END AS aggregated_status,
  COUNT(DISTINCT order_id) AS nr_orders,
   -- I am also looking for the percentage of orders with a specific status over the total:
  ROUND(COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 2) * 100 AS perc_status,
    -- And I create a pivot for my age brackets:
  SUM(CASE WHEN users.age < 20 THEN 1 ELSE 0 END) AS under20,
  SUM(CASE WHEN users.age BETWEEN 20 AND 39 THEN 1 ELSE 0 END) AS age20_39,
  SUM(CASE WHEN users.age BETWEEN 40 AND 59 THEN 1 ELSE 0 END) AS age40_59,
  SUM(CASE WHEN users.age BETWEEN 60 AND 79 THEN 1 ELSE 0 END) AS age60_79,
  SUM(CASE WHEN users.age >= 80 THEN 1 ELSE 0 END) AS over80
FROM `bigquery-public-data.thelook_ecommerce.orders` AS orders
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
ON orders.user_id = users.id
GROUP BY aggregated_status

-- Now, I need to compare returns and cancellations to the overall purchasing activity for each age group 
-- First, I pull the total orders by age bracket:

SELECT
    COUNT(DISTINCT order_id) AS tot_orders,
    SUM(CASE WHEN users.age < 20 THEN 1 ELSE 0 END) AS under20,
    SUM(CASE WHEN users.age BETWEEN 20 AND 39 THEN 1 ELSE 0 END) AS age20_39,
    SUM(CASE WHEN users.age BETWEEN 40 AND 59 THEN 1 ELSE 0 END) AS age40_59,
    SUM(CASE WHEN users.age BETWEEN 60 AND 79 THEN 1 ELSE 0 END) AS age60_79,
    SUM(CASE WHEN users.age >= 80 THEN 1 ELSE 0 END) AS over80
FROM `bigquery-public-data.thelook_ecommerce.orders` AS orders
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
ON orders.user_id = users.id

-- Then, in the case of returns, I calculate the return rate for each age bracket:

SELECT
    ROUND(1688 / 17097 * 100, 2) AS returns_under_20,
    17097 AS tot_under_20,
    ROUND(4262 / 42541 * 100, 2) AS returns_age20_39,
    42541 AS tot_age20_39,
    ROUND(4252 / 42675 * 100, 2) AS returns_age40_59,
    42675 AS tot_age40_59,
    ROUND(2322 / 23167 * 100, 2) AS returns_age60_79,
    23167 AS tot_age60_79