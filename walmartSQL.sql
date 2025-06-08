use walmart;
 
 select count(*) from walmart_cleaned;
 
 select 
	payment_method,
    count(*) as no_payments
from walmart_cleaned
group by payment_method;

select count(distinct branch) from walmart_cleaned;

select min(quantity) from walmart_cleaned;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select 
	payment_method,
    count(*) as no_payments,
    sum(quatity) as no_qty_slod
from walmart
group by payment_method;


 -- Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating-- 

WITH ranked_data AS (
    SELECT 
        branch, 
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`
    FROM walmart_cleaned
    GROUP BY branch, category
)
SELECT branch, category, avg_rating
FROM ranked_data
WHERE `rank` = 1;
        
-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS 'rank'
    FROM walmart_cleaned
    GROUP BY branch, day_name
) AS ranked
WHERE 'rank' = 1;
SELECT branch, category, avg_rating
FROM ranked_data
WHERE `rank` = 1;

-- Q4: Calculate the total quantity of items sold per payment method
SELECT 
	payment_method,
    sum(quantity) as no_qty_sold
from walmart_cleaned
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select 
	city,
    category,
    min(rating) as min_rating,
    max(rating)  as max_rating,
    avg(rating) as avg_rating
from walmart_cleaned
group by city,category;

-- Q6: Calculate the total profit for each category
select 
	category,
    sum(unit_price * quantity * profit_margin) as total_profit
from walmart_cleaned
group by category
order by total_profit desc;
    
-- Q7: Determine the most common payment method for each branch
with cte as (
	select 
    branch,
    payment_method,
    count(*) as total_trans,
    rank() over (PARTITION by branch order by count(*) desc ) as 'rank'
from walmart_cleaned
group by branch,payment_method
)
select branch,payment_method as preferred_payment_method
from cte 
where 'rank' = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart_cleaned
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_cleaned
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_cleaned
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

