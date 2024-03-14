SELECT 
    dp.product_code,
    dp.product_name,
    fe.base_price,
    fe.promo_type
FROM 
    dim_products dp
JOIN 
    fact_events fe ON dp.product_code = fe.product_code
WHERE 
    fe.base_price > 500
    AND fe.promo_type = 'BOGOF';

SELECT
    dc.campaign_id,
    dc.campaign_name,
    SUM(fe.base_price * fe.quantity_sold_before_promo) AS revenue_before_campaign,
    SUM(fe.base_price * fe.quantity_sold_after_promo) AS revenue_after_campaign
FROM
    dim_campaigns dc
JOIN
    fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY
    dc.campaign_id, dc.campaign_name;


DESCRIBE fact_events;
SELECT
    dc.campaign_id,
    dc.campaign_name,
    SUM(fe.base_price * fe.`quantity_sold(before_promo)`) AS revenue_before_campaign,
    SUM(fe.base_price * fe.`quantity_sold(after_promo)`) AS revenue_after_campaign
FROM
    dim_campaigns dc
JOIN
    fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY
    dc.campaign_id, dc.campaign_name;

SELECT
    dp.category,
    SUM(fe.`quantity_sold(before_promo)`) AS total_quantity_sold_before_promo,
    SUM(fe.`quantity_sold(after_promo)`) AS total_quantity_sold_after_promo,
    ((SUM(fe.`quantity_sold(after_promo)`) - SUM(fe.`quantity_sold(before_promo)`)) / SUM(fe.`quantity_sold(before_promo)`) * 100) AS isu_percentage
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
JOIN
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
WHERE
    dc.campaign_id = 'CAMP_DIW_01'
GROUP BY
    dp.category
ORDER BY
    isu_percentage DESC;

SELECT
    category,
    total_quantity_sold_before_promo,
    total_quantity_sold_after_promo,
    isu_percentage,
    ROW_NUMBER() OVER (ORDER BY isu_percentage DESC) AS category_rank
FROM
    (SELECT
        dp.category,
        SUM(fe.`quantity_sold(before_promo)`) AS total_quantity_sold_before_promo,
        SUM(fe.`quantity_sold(after_promo)`) AS total_quantity_sold_after_promo,
        ((SUM(fe.`quantity_sold(after_promo)`) - SUM(fe.`quantity_sold(before_promo)`)) / SUM(fe.`quantity_sold(before_promo)`) * 100) AS isu_percentage
    FROM
        dim_products dp
    JOIN
        fact_events fe ON dp.product_code = fe.product_code
    JOIN
        dim_campaigns dc ON fe.campaign_id = dc.campaign_id
    WHERE
        dc.campaign_id = 'CAMP_DIW_01'
    GROUP BY
        dp.category) AS subquery;

SELECT
    YEAR(STR_TO_DATE(dc.start_date, '%d-%m-%Y')) AS campaign_year,
    MONTH(STR_TO_DATE(dc.start_date, '%d-%m-%Y')) AS campaign_month,
    SUM(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) AS total_revenue
FROM
    dim_campaigns dc
JOIN
    fact_events fe ON dc.campaign_id = fe.campaign_id
GROUP BY
    campaign_year, campaign_month
ORDER BY
    campaign_year, campaign_month;

SELECT
    dp.category,
    dp.product_name,
    AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) AS avg_revenue,
    AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) / (SELECT AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) FROM fact_events fe) AS performance_ratio
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.category, dp.product_name
ORDER BY
    performance_ratio DESC;



