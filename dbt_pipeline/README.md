# DBT Pipeline for Employee Satisfaction Analytics

This DBT project is responsible for the Extract, Transform, Load (ETL/ELT) processes, taking raw survey, employee, and store data, and transforming it into a structured data warehouse in Snowflake. The warehouse consists of staging tables, conformed dimensions, and analytical mart tables that store key performance indicators.

## Project Structure Overview:

*   **`models/`**: Contains all SQL transformation logic.
    *   **`models/staging/`**: For cleaning, standardizing, and preparing raw data.
        *   `sources.yml`: Defines raw data sources in Snowflake.
        *   `stg_*.sql`: SQL files for each staging model.
        *   `staging_schema.yml`: Descriptions and tests for staging models.
    *   **`models/dimensions/`**: For creating dimension tables.
        *   `dim_*.sql`: SQL files for each dimension model.
        *   `dimensions_schema.yml`: Descriptions and tests for dimension models.
    *   **`models/intermediate/`**: For intermediate models used in complex calculations (e.g., for participation rate denominator).
        *   `int_*.sql`: SQL files for intermediate models.
        *   `intermediate_schema.yml`: Descriptions and tests for intermediate models.
    *   **`models/marts/`**: For creating fact/metric tables ready for analytics and API consumption.
        *   `fct_*.sql`: SQL files for each mart model.
        *   `marts_schema.yml`: Descriptions and tests for mart models.
*   **`macros/`**: Contains reusable SQL code snippets (macros).
    *   `filter_by_store_macro.sql`: Example macro for store filtering.

*   **`dbt_project.yml`**: Main configuration file for this DBT project.
*   **`packages.yml`**: Defines DBT package dependencies (e.g., `dbt_utils`, `dbt_expectations`).
*   **`profiles.yml`**: (Located locally in `~/.dbt/`) Contains database connection credentials.

---

## Data Flow & Modeling Strategy:

1.  **Sources:** Raw CSV data (`raw_initial_survey_data`, `raw_incremental_survey_data`, `raw_deleted_records`) is loaded into a `RAW_DATA` schema in Snowflake. These are defined as sources in `models/staging/sources.yml`.
2.  **Staging Layer (`models/staging/`):**
    *   `stg_survey_responses_unioned`: Combines initial and incremental raw survey files.
    *   `stg_deleted_records_cleaned`: Cleans and standardizes the deleted records data.
    *   `stg_survey_responses_base`: Takes the unioned data, performs cleaning, type casting (e.g., dates, scores), basic transformations (e.g., calculating `response_time_days`), and standardizes categorical values (e.g., `employee_status`, `store_rating`).
    *   `stg_survey_responses_final`: Applies soft-deletion logic by joining `stg_survey_responses_base` with `stg_deleted_records_cleaned` and adding an `is_deleted` flag. This is the primary source for downstream dimension and mart models.
3.  **Dimension Layer (`models/dimensions/`):**
    *   `dim_date_extended`: A comprehensive date dimension generated using `dbt_utils.date_spine`, providing various date attributes for flexible time-based analysis.
    *   `dim_employees`: Stores unique employee information (Type 1 SCD - latest record). Uses `dbt_utils.generate_surrogate_key` for `employee_dim_key`.
    *   `dim_stores`: Stores unique store information (Type 1 SCD - latest rating). Uses `dbt_utils.generate_surrogate_key` for `store_dim_key`.
    *   `dim_sub_stores`: Stores unique sub-store information, linked to parent stores (Type 1 SCD). Uses `dbt_utils.generate_surrogate_key` for `sub_store_dim_key`.
4.  **Intermediate Layer (`models/intermediate/`):**
    *   `int_monthly_active_employees_by_location`: Calculates the count of unique active employees per store/sub-store per month, was necessary for the participation rate denominator.
5.  **Mart Layer (`models/marts/`):** These are the final tables ready for consumption by the API.
    *   `fct_monthly_satisfaction`: Aggregates survey scores to provide average monthly satisfaction per store/sub-store. Joins with `dim_date_extended`, `dim_stores`, `dim_sub_stores`.
    *   `fct_avg_response_time`: Aggregates response times to provide average monthly response time in days per store/sub-store. Joins with `dim_date_extended`, `dim_stores`, `dim_sub_stores`.
    *   `fct_participation_rate`: Calculates the monthly participation rate by joining respondent counts with eligible active employee counts (from the intermediate model) per store/sub-store. Joins with `dim_date_extended`, `dim_stores`, `dim_sub_stores`.

---

## Setup & Configuration:

1.  **Install DBT Core and Snowflake Adapter:**
    ```bash
    pip install dbt-core dbt-snowflake
    ```
2.  **Configure `profiles.yml`:**
    *   Ensure you have a `profiles.yml` file (typically in `~/.dbt/`).
    *   Add a profile for this project (e.g., `harri_dbt_pipeline`) with your Snowflake account details, user, password (use environment variables for production), role, warehouse, database (`HARRI_ANALYTICS_DB`), and default target schema (e.g., `MARTS` or `DBT_MODELS`).
    *   *Refer to the main project README or DBT documentation for an example `profiles.yml` structure for Snowflake.*
3.  **Install DBT Packages:**
    *   Navigate to this `dbt_pipeline` directory in your terminal.
    *   Run: `dbt deps`
        *   This will install packages like `dbt_utils` and `dbt_expectations` defined in `packages.yml`.
4.  **Load Raw Data into Snowflake:**
    *   Ensure the three source CSV files (`initial_data.csv`, `incremental_update.csv`, `deleted_records.csv`) are loaded into tables (e.g., `RAW_INITIAL_SURVEY_DATA`, `RAW_INCREMENTAL_SURVEY_DATA`, `RAW_DELETED_RECORDS`) within a schema named `RAW_DATA` in your Snowflake database (`HARRI_ANALYTICS_DB`).

---

## Execution Steps:

From within this `dbt_pipeline` directory:

1.  **Test Connection to Snowflake:**
    ```bash
    dbt debug
    ```
2.  **Build and Run All Models:**
    ```bash
    dbt run
    ```
    *   To run specific models or groups:
        *   `dbt run --select staging.*` (runs all models in the staging directory)
        *   `dbt run --select dim_employees` (runs only the dim_employees model and its parents)
        *   `dbt run --select +fct_monthly_satisfaction` (runs fct_monthly_satisfaction and all its upstream dependencies)
3.  **Run Data Tests:**
    ```bash
    dbt test
    ```
    *   To test specific models:
        *   `dbt test --select model_name`
        *   `dbt test --select source:source_name`
4.  **Generate DBT Documentation:**
    ```bash
    dbt docs generate
    ```
5.  **Serve DBT Documentation Locally:**
    ```bash
    dbt docs serve
    ```
    *   This usually starts a web server on `http://localhost:8080`. Open this URL in your browser to view the project documentation, model details, and lineage graph.

---

## Key Features Implemented:

*   **Sources:** Defined in `models/staging/sources.yml` pointing to raw tables in Snowflake.
*   **Staging Models:**
    *   `stg_survey_responses_base`: Calculates `response_time_days`.
    *   The staging layer effectively filters out non-active employees for metric calculation by ensuring downstream marts only consider surveys from employees with an 'ACTIVE' status in `stg_survey_responses_final`.
*   **Metric Models:**
    *   `fct_monthly_satisfaction`: Calculates average score per store/sub-store per month.
    *   `fct_avg_response_time`: Calculates average days to complete survey per store/sub-store per month.
    *   `fct_participation_rate`: Calculates (survey respondent count ÷ active employee count for that location/month).
*   **Macros:**
    *   `macros/filter_by_store_macro.sql`: Provides a `filter_by_store(column_name)` macro. This can be used to conditionally add a WHERE clause to models if `dbt run` is executed with `--vars '{dbt_store_id_filter: "your_store_id"}'`. This ensures no hard-coding of `store_id` directly within model transformation logic if specific store builds were required. Metric models are built for all stores by default, grouped by store dimensions.
*   **Documentation & Tests:**
    *   `schema.yml` files are provided for staging, dimension, and mart models, including descriptions for models and columns.
    *   Tests include `not_null`, `unique`, `relationships`, and value-based tests using `dbt_utils` and `dbt_expectations`.
*   **Soft Deletion:** Survey responses listed in `deleted_records.csv` are flagged in `stg_survey_responses_final` and excluded from final metric calculations in the mart tables.
*   **Incremental Data Handling (Conceptual):** While models are set to `materialized='table'` for simplicity in this task (implying full refresh), the data model design (especially with surrogate keys and `dwh_updated_at` timestamps) lays a foundation for potential future conversion to `materialized='incremental'` strategies. The current pipeline processes all available source data on each run, incorporating any new data from `raw_incremental_survey_data`.
*   **Partitioning (Snowflake Clustering):** Mart tables are configured with `cluster_by` on relevant date and store key columns to leverage Snowflake's micro-partitioning and improve query performance for common access patterns.

