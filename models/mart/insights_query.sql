-- Top products by total revenue
select
    product_type,
    sum(total_revenue) as revenue,
    min(overall_revenue_rank) as best_rank_achieved
from mart_product_performance
group by product_type
order by revenue desc
limit 5;

-- Best performing store by month
select store_location, transaction_month, monthly_revenue, revenue_rank_in_month
from mart_store_performance
where revenue_rank_in_month = 1
order by transaction_month;

-- Peak hours driving most revenue
select peak_period, sum(total_revenue) as revenue
from mart_hourly_patterns
group by peak_period
order by revenue desc;

-- Insights into employee info
select * from mart_employee_store_summary;