
    
    

with all_values as (

    select
        peak_period as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."mart_hourly_patterns"
    group by peak_period

)

select *
from all_values
where value_field not in (
    'Morning Peak','Lunch Peak','Evening Peak','Off-Peak'
)


