-- Purpose: Combine initial and incremental raw survey data
-- No cleaning or type casting yet, just unioning.

SELECT * FROM {{ source('raw_input_data', 'RAW_INITIAL_DATA') }}
UNION ALL
SELECT * FROM {{ source('raw_input_data', 'RAW_INCREMENTAL_DATA') }}