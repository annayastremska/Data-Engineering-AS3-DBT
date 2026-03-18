{% macro is_peak_hour(time_column) %}
    case
        when date_part('hour', {{ time_column }}) between 7 and 9   then 'Morning Peak'
        when date_part('hour', {{ time_column }}) between 12 and 14  then 'Lunch Peak'
        when date_part('hour', {{ time_column }}) between 17 and 19  then 'Evening Peak'
        else 'Off-Peak'
    end
{% endmacro %}
