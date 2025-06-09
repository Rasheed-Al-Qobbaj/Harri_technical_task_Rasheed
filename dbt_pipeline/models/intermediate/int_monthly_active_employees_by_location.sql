-- models/intermediate/int_monthly_active_employees_by_location.sql
-- Purpose: Determines the count of unique active employees per store/sub-store per month
-- based on their survey activity within that month.
{{
    config(
        materialized='table'
    )
}}

SELECT
    survey_month, -- This is date_trunc('month', survey_date)
    store_id,
    sub_store_id,
    COUNT(DISTINCT employee_id) AS active_employee_count_location
FROM {{ ref('stg_survey_responses_final') }}
WHERE is_deleted = FALSE
  AND employee_status = 'ACTIVE' -- Count only employees marked as active
  AND survey_score IS NOT NULL -- Ensure they actually participated in a survey that month as a proxy for eligibility
                              -- Or use just survey_date if that's the trigger for eligibility
GROUP BY
    survey_month,
    store_id,
    sub_store_id