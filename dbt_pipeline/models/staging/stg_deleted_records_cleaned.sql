-- Purpose: Clean and standardize the deleted records data.
SELECT
    TRIM(survey_id) AS survey_id, -- Assuming IDs might have whitespace
    TRIM(employee_id) AS employee_id,
    TO_TIMESTAMP_NTZ(deleted_at) AS deleted_at_ts -- Cast to Snowflake timestamp
                                                  -- Use TO_TIMESTAMP_LTZ or TO_TIMESTAMP_TZ if timezone info is relevant
FROM {{ source('raw_input_data', 'RAW_DELETED_RECORDS') }}
WHERE NULLIF(TRIM(survey_id), '') IS NOT NULL AND NULLIF(TRIM(employee_id), '') IS NOT NULL -- Basic check