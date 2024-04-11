# Customer Insights 
Understanding our customer base is necessary to improve customer experience and drive overall business growth. 

***Why do we need data analysis?***
- **Marketing campaigns** should be tailored to specific demographics to maximise engagement and sales. 
- Data-driven marketing choices ensure a more **efficient budget allocation**.
- **Product teams** make use of customer insights by creating solutions that are able to resonate with the target audience and ultimately drive retention.
- The **Customer Service department** also takes from demographic data to personalise interaction and ensure satisfaction.

## Business questions
1. Where do our customers come from? Which are the most active countries in terms of purchases?
2. What is our gender segmentation?
3. What is our age segmentation?
4. Who are our most loyal customers?

-----

## 1. Where do our customers come from? Which are the most active countries in terms of purchases?

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
        COUNT(DISTINCT order_id) AS nr_orders
    FROM customer_base
    GROUP BY 
    country
    ORDER BY 
    nr_customers DESC
**![](https://lh7-us.googleusercontent.com/hdKMmevBZAapqS1Pg7m86GNSTrXBXkVYmLIlUzMNIW_W642a1qH2necOxEgTQuiyKExOyYRCQ1wavmprAeANfG5-huUro58OoVM77Tl78I1EbF6A1mD9jBbT3r6hDY_SX4REgeVgTlyRjay6vsDKqlk)**

**Insights:**
 - Majority of our customers come from China, the United States and Brazil.     
 - These countries are also the most popular in terms of purchases made.     
 
-----

## 2. What is our gender segmentation?

**The gender breakdown in this dataset consists of M=males and F=females.*

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
**![](https://lh7-us.googleusercontent.com/bptzuyOtFyuqJ5tvgzPdO7IFeHDdt8fW9ttEn8PrU06MjW5ZycKJr6iQNq7U5Yy45TszEgC_AtyDChniMhVpbnHYLLHgcyXRYT3pAu8lPvuNZD16gglnlg6pfpdEBQz7ta_03IjVNj8zhNI9i3qk3F0)**

**Insights:**
- The overall gender distribution seems quite balanced, with males being only slightly more than women. 
- This agrees with the gender distribution by country (see first query).

----

## 3. What is our age segmentation?

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
**![](https://lh7-us.googleusercontent.com/Grbm9joFel-PpLKsTSMLoJfhZkamtbuuD4EETGxb4NFUfTKdJo0lgGq-jsmstMCuw6_B43eqTbwZXvYhpy1xeuVvXKGFtSAFG2fd9FRSOqKDSiK0UeQYmbOnRo0qF1xZQF-5DKUyFnq33negdngZlnI)**

**Insights:**

- Majority of our customers are age 40-59, followed by the 20-39 age group.
- We have no customers over 80 years old.

----

## 4. Who are our most loyal customers?

Let's say our Marketing team wants to award the five most loyal customers by sending **a promotional email with a special discount**. I will provide a list with their contact email, based on total orders placed.

    SELECT
        CONCAT(b.first_name, ' ', b.last_name) AS full_name,
        STRING_AGG(DISTINCT b.email, ', ') AS email_address,
        COUNT(DISTINCT a.order_id) AS cnt_orders
    FROM `bigquery-public-data.thelook_ecommerce.orders` a
    LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` b
    ON a.user_id = b.id
    GROUP BY 
    full_name
    ORDER BY 
    cnt_orders DESC
    LIMIT 5

**![](https://lh7-us.googleusercontent.com/EwZsa86ziPk0RGo3ORfK9G3paxjvWjCAFlwDvp-OsFA1pdxh-JECfs4iOEaVZuiKbZ3qpU_Nh_ik2mJJdj93ZVUrwLToASIGAikHRZFMazfLi4eKkbcFOWzBPguRlQ9p_xCXbax9OEGf3NUxmf2ObpY)**

**Insights:**
- Our five top buyers purchased with different email addresses throughout their order history with us.
- My recommendation for the Marketing team is to contact each customer to all emails provided to ensure reachability, and share a unique coupon code per customer to ensure single usage. 
- *Bonus insight:* yes, it's a common last name, but the Smith family seem to love our shop! 