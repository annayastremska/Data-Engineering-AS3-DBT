{{
    config(
        materialized='table'
    )
}}

with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select store_id, store_name, city, region
    from {{ ref('dim_stores') }}
),

enriched as (
    select
        e.employee_id,
        e.store_id,
        s.store_name,
        s.city,
        s.region,
        e.first_name,
        e.last_name,
        e.role,
        e.hire_date,
        e.hire_year,
        e.salary_usd,

        case
            when e.salary_usd >= 1500 then 'Senior'
            when e.salary_usd >= 1000 then 'Mid'
            else 'Junior'
        end                                         as salary_band,

        cast(
            date_diff('day', e.hire_date, current_date) / 365.0
        as decimal(5,1))                            as tenure_years

    from employees e
    left join stores s
        on e.store_id = s.store_id
)

select * from enriched
