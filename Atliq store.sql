SELECT
    city,
    COUNT(store_id) AS store_count
FROM
    dim_stores
GROUP BY
    city
ORDER BY
    store_count DESC;

SELECT
    store_id,
    ROUND(avg_revenue, 2) AS avg_revenue,
    performance_ratio
FROM (
    SELECT
        ds.store_id,
        AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) AS avg_revenue,
        ROUND(AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) / (SELECT AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) FROM fact_events fe), 2) AS performance_ratio,
        ROW_NUMBER() OVER (ORDER BY AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) DESC) AS rank_desc,
        ROW_NUMBER() OVER (ORDER BY AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) ASC) AS rank_asc
    FROM
        dim_stores ds
    JOIN
        fact_events fe ON ds.store_id = fe.store_id
    GROUP BY
        ds.store_id
) AS store_performance
WHERE
    rank_desc <= 3 OR rank_asc <= 3
ORDER BY
    rank_desc, rank_asc;

SELECT
    dp.category,
    fe.promo_type,
    AVG(fe.base_price * (fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`)) AS avg_revenue
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.category, fe.promo_type
ORDER BY
    dp.category, avg_revenue DESC;

SELECT
    dp.product_code,
    dp.product_name,
    dp.category,
    fe.promo_type,
    AVG(fe.`quantity_sold(before_promo)`) AS avg_quantity_sold_before_promo,
    AVG(fe.`quantity_sold(after_promo)`) AS avg_quantity_sold_after_promo,
    AVG(fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`) AS avg_change_in_quantity_sold
FROM
    dim_products dp
JOIN
    fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.product_code, dp.product_name, dp.category, fe.promo_type
ORDER BY
    avg_change_in_quantity_sold DESC;

SELECT
    ds.city,
    dp.product_name,
    COUNT(*) AS total_sales
FROM
    dim_stores ds
JOIN
    fact_events fe ON ds.store_id = fe.store_id
JOIN
    dim_products dp ON fe.product_code = dp.product_code
GROUP BY
    ds.city, dp.product_name
ORDER BY
    ds.city, total_sales DESC;

SELECT
    city,
    product_name,
    total_sales,
    RANK() OVER (PARTITION BY city ORDER BY total_sales DESC) AS product_rank
FROM (
    SELECT
        ds.city,
        dp.product_name,
        SUM(fe.`quantity_sold(after_promo)` - fe.`quantity_sold(before_promo)`) AS total_sales
    FROM
        dim_stores ds
    JOIN
        fact_events fe ON ds.store_id = fe.store_id
    JOIN
        dim_products dp ON fe.product_code = dp.product_code
    GROUP BY
        ds.city, dp.product_name
) AS sales_by_city;


