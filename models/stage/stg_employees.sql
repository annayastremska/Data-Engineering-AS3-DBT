with source as (
    select * from {{ ref('raw_employees') }}
),

cleaned as (
    select
        employee_id,
        store_id,
        trim(lower(first_name))             as first_name,
        trim(lower(last_name))              as last_name,
        trim(role)                 as role,       
        cast(hire_date as date)             as hire_date,
        cast(salary as decimal(10, 2))      as salary_usd,
        date_part('year', cast(hire_date as date)) as hire_year
    from source
    where employee_id is not null
      and store_id is not null
)

select * from cleaned