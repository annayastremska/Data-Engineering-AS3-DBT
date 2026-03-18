
    
    

with all_values as (

    select
        day_period as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."mart_hourly_patterns"
    group by day_period

)

select *
from all_values
where value_field not in (
    'Morning Rush','Late Morning','Lunch','Afternoon','Off-Peak'
)


