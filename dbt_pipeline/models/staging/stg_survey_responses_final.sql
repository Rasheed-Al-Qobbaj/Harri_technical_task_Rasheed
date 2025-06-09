-- Purpose: Apply soft deletes to the cleaned survey responses.
SELECT
    srb.*,
    CASE WHEN dr.survey_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_deleted
FROM {{ ref('stg_survey_responses_base') }} srb
LEFT JOIN {{ ref('stg_deleted_records_cleaned') }} dr
    ON srb.survey_id_raw = dr.survey_id -- Join on raw string IDs if types might mismatch before cleaning
    AND srb.employee_id_raw = dr.employee_id