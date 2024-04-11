# Delivery Timeframes
Our chronology of orders is an incredibly powerful tool to diagnose issues concerning delivery, such as delays. Improving the quality of our service positively impacts our CSATs and reviews, contributing to our customer retention.

***Why do we need data analysis?***
- Through this, we address and act on **Customer Service complaints** reaching us regarding long delivery timeframes and other inefficiencies.
- In this way, we can make more informed choices concerning **inventory, shipping modalities (i.e. facilities or third party services), and even brands**.

## Business questions 
1. On average, how long does it take for each product to be delivered?
2. Overall, what's our product segmentation in terms of delivery timeframes?
3. Which products are taking the longest (in days) to be delivered?

-----

## 1. On average, how long does it take for our products to be delivered?

    SELECT
        order_items.product_id as id,
        products.name as name,
        AVG(DATE_DIFF(order_items.delivered_at, order_items.shipped_at, day)) as avg_delivery_days
    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS products
    ON order_items.product_id = products.id
    WHERE
    order_items.delivered_at IS NOT NULL
    GROUP BY 
    id, name
    ORDER BY 
    avg_delivery_days DESC
**![](https://lh7-us.googleusercontent.com/KkzgElAUlSagVD67iIWNEksvOe2z5wtpJecsmX2Xzawu0F8ZGHZoS5Lg6XdNYBxe0iq7ZsxbaG_5StcxAwqGZ-6P2Uw7GTGXojtAO3w1UE239lmoEdft0Uz8nZnO8E9GyrurU3bNzFCmBgl8LyRTslA)**

**Insights:**
- Based on our chronology of orders, we can provide a full list of our products based on average delivery.
- Products are delivered within the same day and 4 days, our longest timeframe.

-----

## 2. Overall, what's our product segmentation in terms of delivery timeframes?

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
**![](https://lh7-us.googleusercontent.com/fqS_31ndMEsJu_3ZGS4d04N6ODSHfQCMYQtnrlPH8wSZyvS_QQOVoLqVllw8R-I7JTFrOWePEmNMfGrFgTGl1MfOwA1i3wNC8BOMy0b8OMPk_2v7oNT0BYb2wwBXHtojiK_2Xt5FsSWzRZBWvZVz_DM)**

**Insights:**
- Looking into our aggregated data, we can see 2565 products have an average 4-days delivery.

-----

## 3. Which products are taking the longest (in days) to be delivered?

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
**![](https://lh7-us.googleusercontent.com/zrB5hhGTET8khqmB6qwT3X35X_AaFYlWr2EwFCz3mhEFd08TgvWD5l0oCWJGA6rJvdBpF1SuU-iwiOWgpMhXINs0ND6SWLcQCUhzpB3TsGRZ6vOYm67urMdHDozyFRODxs_i3JArUKcAVxZSSo2wAg0)**

**Insights:**
- We have provided a list of the 2565 products with average 4-days delivery.
- Further analysis is needed to investigate root causes related to 4-days delivery. Trends might be discovered when looking at specific brands, product categories, delivery address (any specific countries, regions or other conditions), and shipping facilities. 