-- Purpose: Clean data types, handle nulls, derive basic fields from unioned survey responses.
WITH unioned_data AS (
    SELECT * FROM {{ ref('stg_survey_responses_unioned') }}
)
SELECT
    TRIM(survey_id) AS survey_id_raw, -- Keep raw for joining with deleted records if types differ
    TRIM(employee_id) AS employee_id_raw,
    survey_id::INTEGER AS survey_id, -- Attempt cast, handle errors if needed
    employee_id::INTEGER AS employee_id,
    employee_name::VARCHAR AS employee_name,
    TRIM(store_id)::VARCHAR AS store_id,
    TRIM(sub_store_id)::VARCHAR AS sub_store_id,
    survey_score::INTEGER AS survey_score,
    survey_date::DATE AS survey_date,
    response_date::DATE AS response_date,
    DATEDIFF(day, survey_date::DATE, response_date::DATE) AS response_time_days,
    NULLIF(TRIM(UPPER(employee_status)), '')::VARCHAR AS employee_status,
    -- Clean store_rating
    CASE
        WHEN LOWER(TRIM(store_rating)) = 'excellent' THEN 'A'
        WHEN LOWER(TRIM(store_rating)) = 'good' THEN 'B'
        WHEN LOWER(TRIM(store_rating)) = 'average' THEN 'C'
        WHEN LOWER(TRIM(store_rating)) = 'poor' THEN 'D'
        -- Add more specific mappings if '123' has meaning or remove it
        WHEN RLIKE(TRIM(store_rating), '^[0-9]+$') THEN NULL -- If numeric ratings are invalid here
        ELSE NULLIF(TRIM(UPPER(store_rating)), '')
    END AS store_rating_cleaned,
    -- Clean sub_store_capacity
    CASE
        WHEN LOWER(TRIM(sub_store_capacity)) = 'full' THEN 100
        WHEN LOWER(TRIM(sub_store_capacity)) = 'n/a' THEN NULL
        WHEN NULLIF(TRIM(sub_store_capacity), '') IS NULL THEN NULL
        ELSE TRY_CAST(TRIM(sub_store_capacity) AS INTEGER) -- TRY_CAST won't fail if conversion isn't possible
    END AS sub_store_capacity_cleaned,
    DATE_TRUNC('MONTH', survey_date::DATE) AS survey_month,
{#    employee_notes::TEXT,#}
{#    survey_comment::TEXT,#}
{#    legacy_code::VARCHAR#}
FROM unioned_data
WHERE survey_id IS NOT NULL AND employee_id IS NOT NULL -- Basic data quality