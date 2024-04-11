-- 1. On average, how long does it take for our products to be delivered?

SELECT
    order_items.product_id as id,
    products.name as name,
    AVG(DATE_DIFF(order_items.delivered_at, order_items.shipped_at, day)) as avg_delivery_days
-- Let's join two tables as we will need product names (we will only look at products that have been ordered):
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
ON order_items.product_id = products.id
WHERE
order_items.delivered_at IS NOT NULL  -- we want to remove products that have been ordered but not delivered yet
GROUP BY 
id, name
ORDER BY 
avg_delivery_days DESC

-- 2. Overall, what's our product segmentation in terms of delivery timeframes?

WITH a AS
(
    SELECT
        order_items.product_id AS id,
        products.name AS name,
        AVG(DATE_DIFF(order_items.delivered_at, order_items.shipped_at, day)) AS avg_delivery_days
    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id
    WHERE order_items.delivered_at IS NOT NULL
    AND order_items.shipped_at IS NOT NULL
    GROUP BY 
    id, name
    ORDER BY 
    avg_delivery_days DESC
)

SELECT
    COUNT(id) AS tot_products,
    ROUND(a.avg_delivery_days) AS rounded_avg_delivery_days
FROM a
GROUP BY 
rounded_avg_delivery_days
ORDER BY 
rounded_avg_delivery_days DESC

-- 3. Which products are taking the longest (in days) to be delivered?

WITH a AS
(
    SELECT
        order_items.product_id AS id,
        products.name AS name,
        AVG(DATE_DIFF(order_items.delivered_at, order_items.shipped_at, day)) AS avg_delivery_days
    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id
    WHERE 
    order_items.delivered_at IS NOT NULL
    AND order_items.shipped_at IS NOT NULL
    GROUP BY 
    id, name
    ORDER BY 
    avg_delivery_days desc
)

SELECT 
    a.id, 
    a.name, 
    ROUND(a.avg_delivery_days) as rounded_avg_delivery_days
FROM a
WHERE 
ROUND(a.avg_delivery_days) = 4