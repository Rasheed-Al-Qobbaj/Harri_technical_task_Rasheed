-- models/dimensions/dim_sub_stores.sql
-- Purpose: Creates the sub-store dimension table. (Type 1 SCD)
{{
    config(
        materialized='table',
        unique_key='sub_store_dim_key'
    )
}}

WITH sub_store_source_data AS (
    SELECT DISTINCT
        sub_store_id,
        store_id, -- Important for linking to the parent store
        sub_store_capacity_cleaned,
        survey_date -- To determine latest capacity
    FROM {{ ref('stg_survey_responses_final') }}
    WHERE is_deleted = FALSE AND sub_store_id IS NOT NULL AND sub_store_id <> ''
),
latest_sub_store_record AS (
    SELECT
        sub_store_id,
        store_id,
        sub_store_capacity_cleaned,
        ROW_NUMBER() OVER (PARTITION BY sub_store_id, store_id ORDER BY survey_date DESC) as rn
        -- Partition by store_id as well if sub_store_id is not globally unique but unique within a store
    FROM sub_store_source_data
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['sub_store_id', 'store_id']) }} AS sub_store_dim_key, -- Composite business key
    sub_store_id AS sub_store_business_key,
    store_id AS parent_store_business_key, -- This is the FK to dim_stores business key
    sub_store_capacity_cleaned AS current_sub_store_capacity,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_inserted_at,
    CURRENT_TIMESTAMP()::TIMESTAMP AS dwh_updated_at
FROM latest_sub_store_record
WHERE rn = 1