-- models/marts/fct_monthly_satisfaction.sql
-- Purpose: Calculates average monthly employee satisfaction score per store and sub-store.
{{
    config(
        materialized='table',
        unique_key=['satisfaction_month_date_key', 'store_dim_key', 'sub_store_dim_key'],
        cluster_by=['satisfaction_month_date_key', 'store_dim_key']
    )
}}

WITH survey_data AS (
    SELECT
        survey_id,
        employee_id,
        store_id AS store_business_key,
        sub_store_id AS sub_store_business_key,
        survey_score,
        survey_month,
        employee_status
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE
      AND employee_status = 'ACTIVE'
)
SELECT
    dd.date_key AS satisfaction_month_date_key,
    ds.store_dim_key AS store_dim_key,
    COALESCE(dss.sub_store_dim_key, 'MISSING_SUB_STORE_KEY') AS sub_store_dim_key,
    sd.store_business_key,
    sd.sub_store_business_key,
    sd.survey_month AS satisfaction_month,
    AVG(sd.survey_score) AS avg_monthly_satisfaction_score,
    COUNT(DISTINCT sd.survey_id) AS number_of_surveys_fact,
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