-- models/dimensions/dim_date_extended.sql
-- Purpose: Adds useful date attributes to the base date spine.
{{
    config(
        materialized='table',
        unique_key='date_key'
    )
}}

SELECT
    TO_CHAR(date_day, 'YYYYMMDD')::INT AS date_key, -- Primary Key (e.g., 20240519)
    date_day AS full_date,                           -- The actual date value (e.g., 2024-05-19)
    EXTRACT(YEAR FROM date_day) AS calendar_year,
    EXTRACT(MONTH FROM date_day) AS month_of_year,
    TRIM(TO_CHAR(date_day, 'Month')) AS month_name,     -- Full month name (e.g., May)
    TRIM(TO_CHAR(date_day, 'Mon')) AS month_name_short, -- Abbreviated month name (e.g., May)
    EXTRACT(DAY FROM date_day) AS day_of_month,
    EXTRACT(DAYOFWEEKISO FROM date_day) AS day_of_week_iso, -- Monday=1, Sunday=7 (ISO standard)
    TRIM(TO_CHAR(date_day, 'Day')) AS day_of_week_name,   -- Full day name (e.g., Sunday)
    TRIM(TO_CHAR(date_day, 'Dy')) AS day_of_week_name_short, -- Abbreviated day name (e.g., Sun)
    EXTRACT(QUARTER FROM date_day) AS calendar_quarter,
    EXTRACT(WEEKOFYEAR FROM date_day) AS week_of_year,
    DATE_TRUNC('MONTH', date_day)::DATE AS first_day_of_month,
    DATE_TRUNC('QUARTER', date_day)::DATE AS first_day_of_quarter,
    DATE_TRUNC('YEAR', date_day)::DATE AS first_day_of_year,
    LAST_DAY(date_day, 'MONTH')::DATE as last_day_of_month, -- Snowflake specific
    CONCAT('Q', EXTRACT(QUARTER FROM date_day)) AS quarter_name, -- e.g., Q1
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at
FROM {{ ref('dim_date') }} -- This refers to the output of dim_date.sql