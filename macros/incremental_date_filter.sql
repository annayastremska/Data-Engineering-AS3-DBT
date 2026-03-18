{% macro incremental_date_filter(date_column) %}
    {% if is_incremental() %}
        where {{ date_column }} > (
            select max({{ date_column }}) from {{ this }}
        )
    {% endif %}
{% endmacro %}
