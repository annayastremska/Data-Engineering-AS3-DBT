# ☕ Coffee Shop Analytics — dbt + DuckDB

A complete dbt analytical platform built on top of a NYC coffee shop dataset. The project transforms raw CSV seed data through three modelling layers — raw, stage, and mart — landing business-ready tables and insights into a local DuckDB warehouse.

---

## Business Context

The business is a small chain of **three NYC coffee shop locations** (Astoria, Lower Manhattan, Hell's Kitchen). The platform answers core operational questions:

- Which products and categories drive the most revenue?
- Which stores perform best month-over-month, and how fast are they growing?
- What hours of the day generate peak transactions?
- How is the workforce distributed and what does payroll cost per store?
- How does product sales volume trend over time?

---

## Tech Stack

| Tool | Role |
|---|---|
| **dbt Core** | Transformation framework |
| **DuckDB** | Local analytical warehouse (`coffee_shop.duckdb`) |
| **CSV seeds** | Reference data (4 seed files) |

---

## Quick Start

```bash
# 1. Install dependencies
pip install dbt-duckdb

# 2. Clone the repo
git clone https://github.com/annayastremska/Data-Engineering-AS3-DBT.git
cd Data-Engineering-AS3-DBT

# 3. Load the raw source tables into DuckDB
duckdb coffee_shop.duckdb < data/create_tables.sql

# 4. Load seed data
dbt seed

# 5. Run all models
dbt run

# 6. Run tests
dbt test

# 7. (Optional) Full build in one command
dbt build
```

The `profiles.yml` is included in the repo root — no `~/.dbt/profiles.yml` setup needed.

---

## Project Structure

```
coffee_shop/
├── data/
│   ├── coffee_shop_transactions.csv   ← 149 000+ real NYC transactions
│   ├── products_in_stock.csv          ← store–product availability
│   └── create_tables.sql              ← loads the two CSVs into DuckDB
│
├── seeds/
│   ├── customers.csv
│   ├── employees.csv
│   ├── products.csv
│   └── stores.csv
│
├── models/
│   ├── raw/                           ← 6 models  (view)
│   ├── stage/                         ← 6 models  (view)
│   └── mart/                          ← 11 models (table / incremental)
│
├── macros/
│   ├── incremental_date_filter.sql
│   └── is_peak_hour.sql
│
├── tests/
│   ├── assert_all_transaction_stores_in_dim.sql
│   └── assert_revenue_matches_calculation.sql
│
├── dbt_project.yml
├── profiles.yml
└── sources.yml
```

---

## Source Data

The project has two distinct types of source data.

### DuckDB Sources — `data/` (registered in `sources.yml`)

These two large CSV files are loaded directly into DuckDB as native tables using `read_csv_auto` via `data/create_tables.sql`. They are **not** dbt seeds — they are registered as dbt **sources** in `sources.yml` and referenced in raw models via `source()`.

| File | Description | Key columns |
|---|---|---|
| `coffee_shop_transactions.csv` | 149 000+ NYC transactions (Jan–Jun 2023) | `transaction_id`, `transaction_date`, `store_id`, `product_id`, `unit_price`, `transaction_qty` |
| `products_in_stock.csv` | Store–product availability bridge | `store_product_id`, `store_id`, `product_id`, `available_since` |

Load them before running dbt:
```bash
duckdb coffee_shop.duckdb < data/create_tables.sql
```

### dbt Seeds — `seeds/` (loaded via `dbt seed`)

Four smaller reference tables managed directly by dbt and referenced downstream via `ref()`.

| Seed file | Description | Key columns |
|---|---|---|
| `customers.csv` | 12 customer records | `customer_id`, `first_name`, `last_name`, `gender`, `signup_date`, `city` |
| `employees.csv` | 18 employee records across 3 stores | `employee_id`, `role`, `hire_date`, `store_id`, `salary` |
| `products.csv` | 20 product definitions | `product_id`, `product_name`, `category`, `subcategory`, `unit_price` |
| `stores.csv` | 3 NYC store locations | `store_id`, `store_name`, `city`, `region`, `opening_date`, `store_size_sq_m` |

---

## Model Layers

### Raw Layer — `models/raw/` (6 models, materialized as views)

Thin pass-through models. No transformation — just reference the source or seed and make it available for downstream staging models.

| Model | Source |
|---|---|
| `raw_coffee_shop_transactions` | `source('coffee_shop_raw', 'coffee_shop_transactions')` |
| `raw_products_in_stock` | `source('coffee_shop_raw', 'products_in_stock')` |
| `raw_customers` | `ref('customers')` seed |
| `raw_employees` | `ref('employees')` seed |
| `raw_products` | `ref('products')` seed |
| `raw_stores` | `ref('stores')` seed |

---

### Stage Layer — `models/stage/` (6 models, materialized as views)

Clean, standardise, cast, and enrich each raw entity. Business logic stays out — this layer is purely about data quality and type correctness.

| Model | Key transformations |
|---|---|
| `stg_coffee_shop_transactions` | Parses `M/D/YYYY` date format; fixes comma-as-decimal `unit_price` bug; derives `gross_revenue = unit_price × qty`; adds `transaction_year`, `transaction_month`, `day_of_week` |
| `stg_customers` | Lowercases and trims name fields; uppercases `gender`; extracts `signup_year` / `signup_month` |
| `stg_employees` | Casts `salary` to decimal; extracts `hire_year`; filters null `employee_id` or `store_id` |
| `stg_products` | Derives `product_group` (`Beverage` / `Food`) from subcategory |
| `stg_products_in_stock` | Casts `available_since` to date; computes `days_available` |
| `stg_stores` | Uppercases `region`; extracts `opening_year`; casts `store_size_sq_m` to integer |

---

### Mart Layer — `models/mart/` (11 models)

Business-ready tables for reporting and analysis. Structured as dimensions, facts, and analytical marts.

#### Dimensions (materialized as `table`)

| Model | Description | Notable enrichment |
|---|---|---|
| `dim_customers` | One row per customer | `signup_cohort` label (e.g. `2023-Q1`) |
| `dim_stores` | One row per store | `store_size_category` (Small / Medium / Large); `years_in_operation` |
| `dim_products` | One row per product | `price_tier` (Budget / Standard / Premium); `product_group` |
| `dim_employees` | One row per employee, joined to stores | `salary_band` (Junior / Mid / Senior); `tenure_years` |

#### Facts (materialized as `incremental`)

| Model | Grain | Unique key |
|---|---|---|
| `fct_transactions` | One row per transaction | `transaction_id` |
| `fct_daily_revenue` | One row per store per day | `store_id` + `transaction_date` |
| `fct_product_sales` | One row per product per month | `product_id` + `transaction_year` + `transaction_month` |

#### Analytical Marts

| Model | Materialization | Description |
|---|---|---|
| `mart_store_performance` | Incremental | Monthly revenue per store with rankings and MoM growth |
| `mart_product_performance` | Incremental | Monthly product revenue with category rankings and cumulative totals |
| `mart_hourly_patterns` | Table | Revenue and transaction counts by hour of day per store |
| `mart_employee_store_summary` | Table | Headcount, payroll cost, and role breakdown per store |

**Total: 23 models** across three layers.

---

## Incremental Models (5)

Five models use `materialized='incremental'`. On each run, only new records — those with a `transaction_date` greater than the current maximum in the target table — are processed, avoiding a full rebuild.

| Model | Unique key | Incremental column |
|---|---|---|
| `fct_transactions` | `transaction_id` | `transaction_date` |
| `fct_daily_revenue` | `store_id` + `transaction_date` | `transaction_date` |
| `fct_product_sales` | `product_id` + `year` + `month` | `transaction_date` |
| `mart_store_performance` | `store_id` + `year` + `month` | `transaction_date` |
| `mart_product_performance` | `product_id` + `year` + `month` | `transaction_date` |

All five use `on_schema_change='fail'` to prevent silent column drift between runs.

### Incremental Predicate — `incremental_date_filter` macro

The watermark filter is extracted into a reusable macro:

```sql
{% macro incremental_date_filter(date_column) %}
    {% if is_incremental() %}
        where {{ date_column }} > (
            select max({{ date_column }}) from {{ this }}
        )
    {% endif %}
{% endmacro %}
```

Used in models as a one-liner:

```sql
select * from {{ ref('stg_coffee_shop_transactions') }}
{{ incremental_date_filter('transaction_date') }}
```

**Why this predicate?** Without it, every incremental run would scan the full source table to detect new records. The `WHERE` clause pushes the filter down to DuckDB before the join, so only new rows are read. The tradeoff: late-arriving records with a `transaction_date` older than the current maximum are silently skipped — acceptable for append-only transaction logs, but not for sources that backfill historical data.

---

## Macros (2)

### `incremental_date_filter(date_column)`
Generates the `WHERE` clause for incremental models. Eliminates copy-pasted watermark logic across five models. A single change to the macro updates all five models at once.

### `is_peak_hour(time_column)`
Classifies a timestamp into a named business period:

```sql
{% macro is_peak_hour(time_column) %}
    case
        when date_part('hour', {{ time_column }}) between 7 and 9   then 'Morning Peak'
        when date_part('hour', {{ time_column }}) between 12 and 14 then 'Lunch Peak'
        when date_part('hour', {{ time_column }}) between 17 and 19 then 'Evening Peak'
        else 'Off-Peak'
    end
{% endmacro %}
```

Used in both `fct_transactions` and `mart_hourly_patterns`. Without this macro, the same four-branch CASE expression would be duplicated in every model that needs peak period logic — a maintenance risk the moment business hours change.

---

## Window Functions

Window functions appear in four mart models, each serving a real business purpose:

| Model | Function | Business use |
|---|---|---|
| `mart_store_performance` | `rank() over (partition by year, month order by revenue desc)` | Monthly revenue ranking across stores |
| `mart_store_performance` | `sum() over (partition by store_id … rows unbounded preceding)` | Running cumulative revenue per store |
| `mart_store_performance` | `lag() over (partition by store_id order by year, month)` | Prior month revenue for MoM growth % |
| `mart_product_performance` | `dense_rank() over (partition by category, year, month …)` | Product rank within its category each month |
| `mart_product_performance` | `dense_rank() over (partition by year, month …)` | Overall product revenue rank across all categories |
| `mart_product_performance` | `sum() over (partition by product_id … rows unbounded preceding)` | Running cumulative revenue per product |
| `mart_product_performance` | `lag() over (partition by product_id order by year, month)` | Prior month units sold for growth % |
| `mart_hourly_patterns` | `rank() over (partition by store_id order by revenue desc)` | Rank hours by revenue within each store |
| `mart_hourly_patterns` | `sum() over (partition by store_id)` | Each hour's percentage share of total store revenue |

---

## Tests

### Generic tests (YAML — `_stg_models.yml` and `_mart_models.yml`)

| Test | Applied to |
|---|---|
| `unique` + `not_null` | All primary keys: `transaction_id`, `customer_id`, `store_id`, `employee_id`, `product_id`, `store_product_id` |
| `accepted_values` | `gender` (`F`, `M`); `product_group` (`Beverage`, `Food`); `price_tier` (`Budget`, `Standard`, `Premium`); `store_size_category` (`Small`, `Medium`, `Large`); `salary_band` (`Junior`, `Mid`, `Senior`); `peak_period` (4 values) |
| `relationships` | `stg_employees.store_id` → `stg_stores.store_id`; `dim_employees.store_id` → `dim_stores.store_id`; `stg_products_in_stock.product_id` → `stg_products.product_id` |
| `not_null` | Revenue, date, and quantity columns across all fact models |

### Singular (custom) tests — `tests/`

**`assert_all_transaction_stores_in_dim.sql`** — fails if any `store_id` in `fct_transactions` has no matching record in `dim_stores`. Catches referential integrity gaps between the fact table and the store dimension.

**`assert_revenue_matches_calculation.sql`** — fails if `gross_revenue` deviates from `unit_price × transaction_qty` by more than 0.01. Validates that the comma-as-decimal fix applied in staging did not introduce rounding errors downstream.

---

## Business Insights

Run the queries in `insights_query.sql` against the built mart tables:

```sql
-- Top products by total revenue
SELECT product_type, SUM(total_revenue) AS revenue, MIN(overall_revenue_rank) AS best_rank
FROM mart_product_performance
GROUP BY product_type ORDER BY revenue DESC LIMIT 5;

-- Best performing store each month
SELECT store_location, transaction_month, monthly_revenue, revenue_rank_in_month
FROM mart_store_performance
WHERE revenue_rank_in_month = 1 ORDER BY transaction_month;

-- Revenue by peak period
SELECT peak_period, SUM(total_revenue) AS revenue
FROM mart_hourly_patterns
GROUP BY peak_period ORDER BY revenue DESC;

-- Workforce and payroll per store
SELECT * FROM mart_employee_store_summary;
```

Key findings the mart layer surfaces:

- **Morning Peak (7–9 AM)** and **Lunch Peak (12–2 PM)** together account for the majority of daily revenue across all three locations, as seen in `mart_hourly_patterns`.
- **Coffee** leads all product categories on total revenue; brewed and espresso-based drinks dominate both volume and value in `mart_product_performance`.
- Store revenue rankings shift month-over-month — `revenue_rank_in_month` and `revenue_growth_pct` in `mart_store_performance` show which location is accelerating.
- `mart_employee_store_summary` reveals payroll distribution by role (Manager / Supervisor / Barista / Cashier) and average tenure across all three stores.

---

## dbt Concepts Reference

| Term | How it appears in this project |
|---|---|
| **Seed** | Four CSV files in `seeds/` (customers, employees, products, stores) loaded via `dbt seed` and referenced via `ref()` |
| **Source** | `coffee_shop_transactions` and `products_in_stock` loaded into DuckDB from `data/` via `create_tables.sql`, declared in `sources.yml`, and referenced via `source()` |
| **Model** | 23 `.sql` files across raw / stage / mart that define transformations as SELECT statements |
| **Materialization** | Raw and stage → `view`; dimensions and mart summaries → `table`; facts and performance marts → `incremental` |
| **Incremental model** | 5 models that only process rows newer than the current table maximum, controlled by `unique_key` and `on_schema_change` |
| **Macro** | 2 Jinja macros (`incremental_date_filter`, `is_peak_hour`) generating reusable SQL fragments |
| **Test** | Generic YAML tests (unique, not_null, accepted_values, relationships) + 2 singular SQL assertion tests |
| **Staging layer** | `stg_*` models — one model per source entity, clean and cast only, no joins |
| **Mart layer** | `dim_*` dimensions, `fct_*` fact tables, and `mart_*` analytical aggregations |
| **Window function** | Used across 4 mart models for ranking, running totals, and period-over-period comparisons |
| **Surrogate key** | `store_product_id` in `stg_products_in_stock` acts as composite surrogate for the store–product bridge |
| **Grain** | `fct_transactions` = one row per transaction; `fct_daily_revenue` = one row per store per day; `fct_product_sales` = one row per product per month |
| **Lineage** | DuckDB sources + seeds → Raw → Stage → Mart; visualised via `dbt docs generate && dbt docs serve` |
| **Dependency** | Managed via `ref()` and `source()` — dbt resolves build order automatically |
| **Data quality** | Enforced through YAML generic tests, singular SQL tests, and `on_schema_change='fail'` guards on all incremental models |
