
    
    

select
    store_id as unique_field,
    count(*) as n_records

from "coffee_shop"."main"."mart_employee_store_summary"
where store_id is not null
group by store_id
having count(*) > 1


