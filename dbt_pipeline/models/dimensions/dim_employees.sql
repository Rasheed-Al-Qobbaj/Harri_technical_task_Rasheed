-- models/dimensions/dim_employees.sql
-- Purpose: Creates the employee dimension table.
-- This version implements a Type 1 SCD (Slowly Changing Dimension),
-- meaning it always reflects the latest known information for an employee.
{{
    config(
        materialized='table',
        unique_key='employee_dim_key'
    )
}}

WITH employee_source_data AS (
    -- Select distinct employee information from your cleaned staging data
    -- where surveys are not deleted.
    SELECT DISTINCT
        employee_id,
        employee_name,
        employee_status, -- This should be the cleaned status from staging
        survey_date      -- Needed to determine the "latest" record for an employee
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE -- Only consider non-deleted survey contexts for employee info
),
latest_employee_record AS (
    SELECT
        employee_id,
        employee_name,
        employee_status,
        -- Use ROW_NUMBER to pick the latest record for each employee based on survey_date
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY survey_date DESC) as rn
    FROM employee_source_data
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS employee_dim_key, -- Surrogate PK
    employee_id AS employee_business_key, -- The original ID
    employee_name,
    employee_status AS current_employee_status,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_inserted_at, -- Or dwh_updated_at
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at   -- For Type 1, insert and update time can be the same
FROM latest_employee_record
WHERE rn = 1 -- This ensures we only get one (the latest) record per employee