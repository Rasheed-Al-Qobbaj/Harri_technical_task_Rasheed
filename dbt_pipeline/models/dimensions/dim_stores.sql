-- models/dimensions/dim_stores.sql
-- Purpose: Creates the store dimension table. (Type 1 SCD - latest rating)
{{
    config(
        materialized='table',
        unique_key='store_dim_key'
    )
}}

WITH store_source_data AS (
    SELECT DISTINCT
        store_id,
        store_rating_cleaned, -- From stg_survey_responses_final
        survey_date           -- To determine the latest rating
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE AND store_id IS NOT NULL AND store_id <> '' -- Ensure store_id is valid
),
latest_store_record AS (
    SELECT
        store_id,
        store_rating_cleaned,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY survey_date DESC) as rn
    FROM store_source_data
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['store_id']) }} AS store_dim_key,
    store_id AS store_business_key,
    store_rating_cleaned AS current_store_rating,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_inserted_at,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at
FROM latest_store_record
WHERE rn = 1