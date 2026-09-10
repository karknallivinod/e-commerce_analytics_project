use `e-commerce_project`;

select count(*) from customers
union all
select count(*) from products
union all
select count(*) from orders
union all
select count(*) from order_items;

select * from orders limit 5;

with cte as (
select
sum(case when order_status='Delivered' then 1 else 0  end) as Delivered,
sum(case when order_status='Cancelled' then 1 else 0 end) as Cancelled,
sum(case when order_status='Returned' then 1 else 0 end) as Returned,
count(*) as total_numbers
from orders
)

select
Delivered,
round(sum(Delivered/total_numbers * 100),2) as Delivery_percent,
Cancelled,
round(sum(Cancelled/total_numbers * 100),2) as Cancelled_percent,
Returned,
round(sum(Returned/total_numbers * 100),2) as Return_percent
from cte
group by Delivered,Cancelled,Returned;

-- Here i think i need two tabels : orders (date,order_status)and order_items (revenue) 
-- Task 2: What is the total revenue per month (Delivered orders only), 
select
	date_format(o.order_date,'%Y-%m') as month,
    round(sum(od.total_amount),2) as revenue,
    count(distinct o.order_id) as orders
from orders o
join order_items od on o.order_id=od.order_id
where o.order_status='Delivered'
group by date_format(o.order_date,'%Y-%m') order by month;

-- Task 3 — Month-over-Month Revenue Growth %
with monthly as
(select
	date_format(o.order_date,'%Y-%m') as month,
    round(sum(od.total_amount),2) as revenue,
    count(distinct o.order_id) as orders
from orders o
join order_items od on o.order_id=od.order_id
where o.order_status='Delivered'
group by date_format(o.order_date,'%Y-%m') order by month
) 
select
	month,
    revenue,
    round((revenue-lag(revenue) over(order by month))/lag(revenue) over(order by month) * 100,2) as month_on_month_per_change
from monthly;

-- Task 4 — Revenue & Profit Margin by Category

with revenue_profit as(
select
	p.category,
    round(sum(p.cost_price*od.quantity),2)as cp,
    round(sum(p.selling_price*od.quantity),2) as sp,
    round(sum(total_amount),2) as total_revenue
from products p
join order_items od on p.product_id=od.product_id
join orders o on od.order_id=o.order_id
where o.order_status='Delivered'
group by p.category
) 
select
	category,
    total_revenue,
    cp as total_cost,
    round(total_revenue-cp,2) as total_profit,
    round((total_revenue-cp)/cp *100,2) as profit_margin
from revenue_profit
order by profit_margin desc;

-- Task 5 customer_id, last_order_date, frequency, monetary
with cte_3 as(
select 
	o.customer_id,
    max(o.order_date) as last_order_date,
    count(distinct od.order_id) as frequency,
    round(sum(total_amount),2) as monetary,
    (select max(order_date) as last_order_date from orders where order_status='Delivered') as snapshot_date
from orders o 
join order_items od on o.order_id=od.order_id
where o.order_status='Delivered'
group by o.customer_id
)

SELECT
    customer_id,
    last_order_date,
    frequency,
    monetary,
    DATEDIFF(snapshot_date, last_order_date) AS recency
FROM cte_3;

-- Task 6:
WITH cte_4 AS (
    SELECT 
        o.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(total_amount), 2) AS monetary,
        (SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered') AS snapshot_date
    FROM orders o 
    JOIN order_items od ON o.order_id = od.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),
cte_5 AS (
    SELECT
        customer_id,
        frequency,
        monetary,
        DATEDIFF(snapshot_date, last_order_date) AS recency
    FROM cte_4
),
rfm_scored AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM cte_5
),
rfm_final as(
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_score
FROM rfm_scored
ORDER BY rfm_score DESC
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_score,
    CASE
        WHEN rfm_score >= 10 THEN 'Champions'
        WHEN rfm_score >= 8  THEN 'Loyal Customers'
        WHEN rfm_score >= 6  THEN 'Potential Loyalists'
        WHEN rfm_score >= 4  THEN 'Needs Attention'
        ELSE 'At Risk / Churned'
    END AS segment
FROM rfm_final
ORDER BY rfm_score DESC;

-- verification
SELECT segment, COUNT(*) AS customers, ROUND(AVG(monetary), 0) AS avg_spend
FROM (
    WITH cte_4 AS (
    SELECT 
        o.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(total_amount), 2) AS monetary,
        (SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered') AS snapshot_date
    FROM orders o 
    JOIN order_items od ON o.order_id = od.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),
cte_5 AS (
    SELECT
        customer_id,
        frequency,
        monetary,
        DATEDIFF(snapshot_date, last_order_date) AS recency
    FROM cte_4
),
rfm_scored AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM cte_5
),
rfm_final AS (
    SELECT
        customer_id,
        recency, frequency, monetary,
        r_score, f_score, m_score,
        (r_score + f_score + m_score) AS rfm_score
    FROM rfm_scored
)
SELECT
    customer_id,
    recency, frequency, monetary,
    r_score, f_score, m_score,
    rfm_score,
    CASE
        WHEN rfm_score >= 10 THEN 'Champions'
        WHEN rfm_score >= 8  THEN 'Loyal Customers'
        WHEN rfm_score >= 6  THEN 'Potential Loyalists'
        WHEN rfm_score >= 4  THEN 'Needs Attention'
        ELSE 'At Risk / Churned'
    END AS segment
FROM rfm_final
ORDER BY rfm_score DESC
) t
GROUP BY segment
ORDER BY avg_spend DESC;