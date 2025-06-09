# Harri Technical Task: Multi-Tenant Employee Satisfaction Analytics Solution

Submitted by: Rasheed Alqobbaj

## Project Overview

This project implements a multi-tenant analytics solution designed to track and analyze employee satisfaction across a chain of stores and their sub-stores. The system processes raw survey, employee, and store data through an ETL pipeline built with **DBT** and a **Snowflake** data warehouse, and presents KPIs via a **Spring Boot REST API**.

The primary goal was to create a scalable and maintainable system focusing on clear data modeling, reusable DBT pipelines for transforming raw data into actionable metrics, and a secure, performant API design for accessing these insights.

### Core Features:

*   **Data Ingestion & Transformation (DBT & Snowflake):**
    *   Handles initial and incremental data loads.
    *   Implements soft deletion for survey records.
    *   Transforms raw data into well-defined staging models, dimension tables (Employees, Stores, Sub-Stores, Date), and metric-focused fact tables (Marts).
    *   Calculates core metrics:
        *   Monthly Satisfaction Score (per store/sub-store)
        *   Average Survey Response Time (per store/sub-store, monthly)
        *   Survey Participation Rate (per store/sub-store, monthly)
    *   Employs DBT best practices including sources, staging, marts, reusable macros (for store ID filtering logic), schema tests, and documentation.
*   **API Exposure (Spring Boot):**
    *   Exposes the calculated metrics via RESTful API endpoints.
    *   Designed with a Three-Tier Architecture (Controller, Service, Repository).
    *   Includes logging for request tracking and error monitoring.
    *   Provides basic exception handling for API requests.
*   **Multi-Tenant Design:**
    *   The data model and DBT pipeline are structured to support multi-tenancy, primarily through `store_id` and `sub_store_id` dimensions.
    *   Metrics are calculated and can be filtered at the store and sub-store level.
    *   The API design is intended to enforce data segregation based on tenancy (e.g., a user/API key for one store should only access data for that store).
*   **Simple UI:**
    *   A basic HTML/JavaScript interface is provided to demonstrate API calls for fetching and displaying the metrics.

### Architecture:

1.  **Data Source:** Raw data was provided in CSV format (initial load, incremental updates, deleted records).
2.  **Data Loading:** CSVs are loaded into a `RAW_DATA` schema in Snowflake.
3.  **ETL/ELT with DBT & Snowflake:**
    *   **Sources:** DBT sources are defined pointing to the raw tables in Snowflake.
    *   **Staging Layer:** Raw data is cleaned, standardized, types are cast, and basic transformations (like calculating `response_time_days` and handling employee status) are performed. Soft deletes are flagged.
    *   **Dimension Layer:** Conformed dimensions (`dim_employees`, `dim_stores`, `dim_sub_stores`, `dim_date_extended`) are built from the staging layer, representing the latest state (Type 1 SCD).
    *   **Mart Layer:** Metric-specific fact tables (`fct_monthly_satisfaction`, `fct_avg_response_time`, `fct_participation_rate`) are created by joining staged survey data with dimensions and performing aggregations.
4.  **API Layer (Spring Boot):**
    *   Reads directly from the DBT-created Mart tables in Snowflake using JDBC.
    *   Exposes REST endpoints for each of the core metrics.
    *   Handles request parameters for filtering by store, sub-store, and month.
5.  **Presentation Layer:**
    *   A simple HTML page uses AJAX (JavaScript Fetch API) to call the Spring Boot APIs and display the metrics.

---

## Project Structure:
```
./
├── dbt_pipeline/ # Contains the full DBT project
│ ├── models/
│ │ ├── staging/
│ │ ├── dimensions/
│ │ ├── intermediate/
│ │ └── marts/
│ ├── macros/
│ ├── packages.yml
│ ├── dbt_project.yml
│ └── ...
├── spring_boot_api/ # Contains the Spring Boot application
│ ├── src/
│ │ ├── main/
│ │ │ ├── java/com/rasheed/harri/api/
│ │ │ │ ├── controller/
│ │ │ │ ├── service/
│ │ │ │ ├── repository/
│ │ │ │ ├── dto/
│ │ │ │ ├── config/
│ │ │ │ └── ApiApplication.java
│ │ │ └── resources/
│ │ │ ├── static/index.html
│ │ │ └── application.properties
│ ├── pom.xml 
│ └── ...
└──
```

---

## Setup Instructions:

Detailed setup instructions for each component can be found in their respective README files:

*   **DBT Pipeline Setup:** [./dbt_pipeline/README.md](./dbt_pipeline/README.md)
*   **Spring Boot API Setup:** [./spring_boot_api/README.md](./spring_boot_api/README.md)

**General Prerequisites:**
*   Git
*   Python (for DBT)
*   Java JDK (Version 17 or higher, as configured in the Spring Boot project)
*   Access to a Snowflake account (my free trial account was sufficient)

---

## Key Design Decisions & Assumptions:

*   **Data Model:** A star schema approach was chosen for the mart tables for query performance, with conformed dimensions for employees, stores, sub-stores, and date. Surrogate keys are used for dimension primary keys.
*   **DBT Materializations:** Staging models are generally views, dimension models are tables, and fact/mart models are tables.
*   **Soft Deletes:** Handled by flagging records in the `stg_survey_responses_final` model based on the `deleted_records.csv` and filtering them out in downstream mart calculations.
*   **Active Employees (for Participation Rate):** The definition of an "active employee" for the denominator of the participation rate is based on employees marked 'ACTIVE' who have submitted at least one non-deleted survey within the reporting month for a given store/sub-store. 
*   **Store/Sub-Store Hierarchy:** Assumed `sub_store_id` is unique within a `store_id`, but not necessarily globally unique. `dim_sub_stores` links to `dim_stores`.
*   **Snowflake for DWH:** Since Harri is going to use Snowflake I felt like it was a good opportunity to tinker with it. 
*   **Spring Boot with JdbcTemplate:** Used `JdbcTemplate` for data retrieval from Snowflake marts to provide direct SQL control and simplify database interaction without the full JPA entity lifecycle management for these read-heavy metric tables.
*   **Incremental Data Handling (DBT):** While the task asks for this, full incremental materializations in DBT were conceptualized but the current implementation focuses on robust full refreshes of marts from comprehensively staged data that incorporates soft deletes. Incremental models (`materialized='incremental'`) could be a next step for optimizing large datasets.
*   **Partitioning (Snowflake):** Utilized `cluster_by` on mart tables in Snowflake on common filter columns (e.g., month, store_id) to optimize query performance.

---

## Presentation Outline:

A presentation will be prepared covering:
1.  Data Model Design (ERD, schema choices).
2.  DBT Pipeline Walkthrough (sources, staging logic, dimension creation, metric calculation in marts, macro usage, testing strategy).
3.  Spring Boot API Design (3-tier architecture, endpoint definitions, request/response flow).
4.  Functional Design (How metrics are derived and exposed).
5.  Multi-tenancy Implementation (Data segregation strategy).
6.  Approach to "Expected Behaviours" (Parallelism, Incremental Data, Partitioning).
7.  Assumptions Made and Potential Future Enhancements.

---

*Thank you for this challenging and insightful task!* I had to learn a lot of new stuff to complete it so it was fun.