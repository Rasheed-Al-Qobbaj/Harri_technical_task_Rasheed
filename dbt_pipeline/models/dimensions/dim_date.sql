-- models/dimensions/dim_date.sql
-- Purpose: Generates a base date spine table with one row per day.
{{
    config(
        materialized='table'
    )
}}

{{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="dateadd(year, 3, current_date())"
    )
}}