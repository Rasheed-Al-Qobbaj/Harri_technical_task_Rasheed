{% macro filter_by_store(column_name) %}
  {% if var('dbt_store_id_filter', none) is not none %}
    {{ column_name }} = '{{ var("dbt_store_id_filter") }}'
  {% else %}
    true
  {% endif %}
{% endmacro %}