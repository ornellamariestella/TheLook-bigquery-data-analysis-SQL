# Order Status
Analysing cancelled or returned orders for an e-commerce store can reveal trends and patterns in customer behaviour, one of them being customer segments that are more likely to experience issues. 

***Why do we need data analysis?***
- **Common issues experienced by customers** can be identified and tackled, improving customer experience.
- Issues might apply to **specific customer segments**. Data help us discover why, and how to fix them.
- Data-driven insights help us formulate strategies to improve **inventory and logistics management**.
- **Costs associated with returned and cancelled orders** can be effectively lowered. 

## Business question
1. How many of our orders got cancelled or returned? Is there a correlation between problematic orders and customers’ age?

-----

## 1. How many of our orders got cancelled or returned? Is there a correlation between problematic orders and customers’ age?

For this analysis, I am interested in problematic statuses only (= returned and cancelled orders) and their age brackets:

    SELECT 
        CASE
            WHEN orders.status IN ('Complete', 'Shipped', 'Processing') THEN 'Unproblematic'
            ELSE orders.status
        END AS aggregated_status,
        COUNT(DISTINCT order_id) AS nr_orders,
        ROUND(COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 2) * 100 AS perc_status,
        SUM(CASE WHEN users.age < 20 THEN 1 ELSE 0 END) AS under20,
        SUM(CASE WHEN users.age BETWEEN 20 AND 39 THEN 1 ELSE 0 END) AS age20_39,
        SUM(CASE WHEN users.age BETWEEN 40 AND 59 THEN 1 ELSE 0 END) AS age40_59,
        SUM(CASE WHEN users.age BETWEEN 60 AND 79 THEN 1 ELSE 0 END) AS age60_79,
        SUM(CASE WHEN users.age >= 80 THEN 1 ELSE 0 END) AS over80
    FROM 
    `bigquery-public-data.thelook_ecommerce.orders` AS orders
    LEFT JOIN 
    `bigquery-public-data.thelook_ecommerce.users` AS users
    ON orders.user_id = users.id
    GROUP BY 
    aggregated_status
**![](https://lh7-us.googleusercontent.com/JyrMt7DbEzsE5KBx8K7Nh327mIGsZhZ1wHdhDgczJrh6FAVbxjk7dMIezPjoysp7G2rJczT_RbSgffQb5TcOHWq3_MxHfTtLCKaChTIZ1uBmxMPwFNyjrt1GAloDF2Vt5nvY4VyzqqJA4jvjAp5wU2c)**

**Preliminary insights:**
 - Roughly 15% orders got cancelled, while 10% of orders got returned*
 **Please note no timeframe was specified for this analysis*
 - The remaining 75% are, as of now, flagged as unproblematic.
 - Customers from age groups 20-39 and 40-59 seem to be returning and cancelling orders more often. **However, they also seem to be purchasing more than any other age brackets**.

To gain a better understanding, we need to look at our data in **relative terms**, thus compare returns and cancellations to the overall purchasing activity for each age group:

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
**![](https://lh7-us.googleusercontent.com/ztIzumBz3x41X-q6dIgFjNrAfQZqOjlZ4hXr6jUVVQZYGoP5eX4Q1rkmjlBC-olxIXAEBK2S0CRta3dm9Bf0-6_VDgibEFxG_qrDqCTyD2m8WSfPbbu5hlIhCO8xaTe3kjwRtcRTlKu009YLE4YlnE4)**

Now, Let’s take a look at our **return rate**, for instance: 

    SELECT
        ROUND(1688 / 17097 * 100, 2) AS returns_under_20,
        17097 AS tot_under_20,
        ROUND(4262 / 42541 * 100, 2) AS returns_age20_39,
        42541 AS tot_age20_39,
        ROUND(4252 / 42675 * 100, 2) AS returns_age40_59,
        42675 AS tot_age40_59,
        ROUND(2322 / 23167 * 100, 2) AS returns_age60_79,
        23167 AS tot_age60_79
**![](https://lh7-us.googleusercontent.com/Wjn2jccTay2U_m5q7r6_VkA80IlVKbzEgkIUHJVyv9wiKiO1jhhQVkA9HlurmxIQWQ_gHL4lnb5DT2EZMRZfrBf2hlx3xpyIbNxLw0K7pPm9uvIZvopVD-imCedVyqGsiT3dQE97tfqidTUMKghXIx4)**

**Final insights:**
 - In relative terms, age groups 20-39 and 60-79 seem to have slightly higher return rates. 
 - This constrasts our initial analysis, where customers age 20-39 and 40-59 seemed to be the ones returning and cancelling orders the most. 
 - We can also see that age bracket 60-79 did not catch our eyes at all in our first analysis.
 - Overall, age doesn’t seem to play a role when checking return rates.
 - However, we can extend our analysis to *other variables* that might be related: type of product/s purchased, categories, brands, delivery timeframes, and more.