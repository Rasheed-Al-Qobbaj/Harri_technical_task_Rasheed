-- models/marts/fct_avg_response_time.sql
-- Purpose: Calculates average monthly survey response time in days per store/sub-store.
{{
    config(
        materialized='table',
        unique_key=['response_month_date_key', 'store_dim_key', 'sub_store_dim_key'],
        cluster_by=['response_month_date_key', 'store_dim_key']
    )
}}

WITH survey_data AS (
    SELECT
        store_id AS store_business_key,
        sub_store_id AS sub_store_business_key,
        survey_month, -- The month the survey was taken/available
        response_time_days
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE
      AND response_time_days IS NOT NULL -- Only include responses where time can be calculated
      AND employee_status = 'ACTIVE' -- Optional: if only for active employees' responses
)
SELECT
    dd.date_key AS response_month_date_key,
    ds.store_dim_key,
    COALESCE(dss.sub_store_dim_key, 'MISSING_SUB_STORE_KEY') AS sub_store_dim_key,
    sd.store_business_key,
    sd.sub_store_business_key,
    sd.survey_month AS response_month,

    AVG(sd.response_time_days) AS monthly_avg_response_time_days,
    COUNT(*) AS total_responses_for_avg_time, -- Count of responses included in this avg

    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_inserted_at,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at
FROM survey_data sd
JOIN {{ ref('dim_date_extended') }} dd
    ON sd.survey_month = dd.full_date
JOIN {{ ref('dim_stores') }} ds
    ON sd.store_business_key = ds.store_business_key
LEFT JOIN {{ ref('dim_sub_stores') }} dss
    ON sd.sub_store_business_key = dss.sub_store_business_key
    AND sd.store_business_key = dss.parent_store_business_key
GROUP BY
    dd.date_key,
    ds.store_dim_key,
    COALESCE(dss.sub_store_dim_key, 'MISSING_SUB_STORE_KEY'),
    sd.store_business_key,
    sd.sub_store_business_key,
    sd.survey_month