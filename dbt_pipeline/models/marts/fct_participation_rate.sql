-- models/marts/fct_participation_rate.sql
-- Purpose: Calculates monthly survey participation rate per store/sub-store.
{{
    config(
        materialized='table',
        unique_key=['survey_month_date_key', 'store_dim_key', 'sub_store_dim_key'],
        cluster_by=['survey_month_date_key', 'store_dim_key']
    )
}}

WITH monthly_survey_respondents AS (
    -- Counts unique employees who responded to a survey (not deleted) in a given month/store/sub-store
    SELECT
        survey_month,
        store_id AS store_business_key,
        sub_store_id AS sub_store_business_key,
        COUNT(DISTINCT employee_id) AS survey_respondent_count
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE
      AND employee_status = 'ACTIVE' -- Only count responses from active employees
    GROUP BY
        survey_month,
        store_id,
        sub_store_id
),
monthly_eligible_employees AS (
    -- Uses the intermediate model for active employees
    SELECT
        survey_month,
        store_id AS store_business_key,
        sub_store_id AS sub_store_business_key,
        active_employee_count_location AS total_eligible_employee_count
    FROM {{ ref('int_monthly_active_employees_by_location') }}
)
SELECT
    dd.date_key AS survey_month_date_key,
    ds.store_dim_key,
    COALESCE(dss.sub_store_dim_key, 'MISSING_SUB_STORE_KEY') AS sub_store_dim_key,
    resp.store_business_key,
    resp.sub_store_business_key,
    resp.survey_month,

    resp.survey_respondent_count AS survey_response_count_fact,
    COALESCE(elig.total_eligible_employee_count, 0) AS active_employee_count_fact,
    CASE
        WHEN COALESCE(elig.total_eligible_employee_count, 0) > 0
        THEN (resp.survey_respondent_count::DECIMAL / elig.total_eligible_employee_count) * 100.0
        ELSE 0.0
    END AS participation_rate_percentage,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_inserted_at,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at
FROM monthly_survey_respondents resp
JOIN monthly_eligible_employees elig
    ON resp.survey_month = elig.survey_month
    AND resp.store_business_key = elig.store_business_key
    AND COALESCE(resp.sub_store_business_key, 'N/A_SUB_STORE') = COALESCE(elig.sub_store_business_key, 'N/A_SUB_STORE') -- Handle NULLs in join
JOIN {{ ref('dim_date_extended') }} dd
    ON resp.survey_month = dd.full_date
JOIN {{ ref('dim_stores') }} ds
    ON resp.store_business_key = ds.store_business_key
LEFT JOIN {{ ref('dim_sub_stores') }} dss
    ON resp.sub_store_business_key = dss.sub_store_business_key
    AND resp.store_business_key = dss.parent_store_business_key
WHERE {{ filter_by_store('resp.store_business_key') }}