# Spring Boot Metrics API for Employee Satisfaction Analytics

This Spring Boot application serves as the API layer for the Employee Satisfaction Analytics solution. It exposes RESTful endpoints to retrieve pre-calculated metrics that have been processed by the DBT pipeline and stored in the Snowflake data warehouse.

## Project Overview:

The primary function of this API is to provide access to key employee satisfaction metrics:
*   Monthly Satisfaction Score
*   Average Survey Response Time
*   Survey Participation Rate

These metrics can be queried with filters for `store_id`, optionally `sub_store_id`, and `month`. The application follows a three-tier architecture (Controller, Service, Repository) and focuses on clear API design, data retrieval from Snowflake, logging, and exception handling.

## Architecture (Spring Boot Component):

1.  **Data Source:** The API connects directly to the mart tables (e.g., `fct_monthly_satisfaction`, `fct_avg_response_time`, `fct_participation_rate`) in the Snowflake data warehouse. These tables are populated and managed by the DBT pipeline.
2.  **Configuration (`application.properties`):** Contains connection details for the Snowflake data warehouse, server port, and other application settings.
3.  **Repository Layer (`com.rasheed.harri.api.repository`):**
    *   Responsible for all database interactions.
    *   Uses Spring's `JdbcTemplate` for executing SQL queries against the Snowflake mart tables.
    *   Employs `RowMapper` implementations to map `ResultSet` data to Data Transfer Objects (DTOs).
4.  **Service Layer (`com.rasheed.harri.api.service`):**
    *   Contains the business logic for fetching and preparing metric data.
    *   Orchestrates calls to the `MetricsRepository`.
    *   Handles parameter preparation (e.g., converting `YearMonth` to `LocalDate`).
    *   Includes logging for request processing and potential issues.
5.  **Controller Layer (`com.rasheed.harri.api.controller`):**
    *   Exposes RESTful API endpoints using Spring MVC (`@RestController`, `@GetMapping`, `@RequestParam`).
    *   Handles incoming HTTP requests, validates parameters, and delegates to the `MetricsService`.
    *   Formats and returns responses (typically JSON) using `ResponseEntity`.
6.  **DTOs (Data Transfer Objects) (`com.rasheed.harri.api.dto`):**
    *   Simple Java Objects used to structure the data returned by the API endpoints. Lombok is used to reduce boilerplate code.
8.  **Simple UI (`src/main/resources/static/index.html`):**
    *   A basic HTML page with JavaScript (Fetch API) is provided to demonstrate making AJAX calls to the API endpoints and displaying the retrieved metric data. This UI is for demonstration purposes only and is not feature-rich.

---

## Project Structure:

*   **`src/main/java/com/rasheed/harri/api/`**: Root package for Java source code.
    *   `ApiApplication.java`: Main Spring Boot application class.
    *   `controller/MetricsController.java`: Defines REST API endpoints.
    *   `service/MetricsService.java`: Implements business logic.
    *   `repository/MetricsRepository.java`: Handles database interactions via `JdbcTemplate`.
    *   `dto/*.java`: Data Transfer Objects for API responses.
    *   `config/SecurityConfig.java`: (If you implement basic security, otherwise omit this line or note it's conceptual).
*   **`src/main/resources/`**:
    *   `application.properties`: Application configuration (DB connection, server port).
    *   `static/index.html`: Simple HTML page for UI demonstration.
*   **`pom.xml`**: Project build and dependency management.

---

## Setup & Execution:

**Prerequisites:**
*   Java JDK 17.
*   Apache Maven 3.6+.
*   Access to the Snowflake instance populated by the DBT pipeline.

**1. Configure Database Connection:**
   *   Open `src/main/resources/application.properties`.
   *   Ensure the `spring.datasource.url`, `username`, and `password` properties are correctly configured to point to your Snowflake data warehouse, specifically the database and schema containing the DBT mart tables (e.g., `HARRI_ANALYTICS_DB.MARTS`).
   *   Update the `warehouse` and `role` parameters in the JDBC URL as needed for your Snowflake setup.

**2. Build the Application:**

Navigate to the `springboot_api` directory in your terminal and run:

```bash
mvn clean install
```

This will compile the code and package the application into a JAR file in the `target/` directory (e.g., `api-0.0.1-SNAPSHOT.jar`).


**3. Run the Application:**
   *   Once built, you can run the application from the JAR file: `java -jar target/api-0.0.1-SNAPSHOT.jar`
   *   Alternatively, you can run the application directly from your IDE by running the `main` method in `ApiApplication.java`.
   *   The application will start an embedded Tomcat server, on port 8081 (as configured in `application.properties`)

---

## API Usage:

The API exposes endpoints under the base path `/api/v1/metrics`.

**Endpoints:**

1.  **Get Monthly Satisfaction Score:**
    *   **Endpoint:** `GET /api/v1/metrics/monthly-satisfaction`
    *   **Query Parameters:**
        *   `store_id` (String, required): e.g., `S1`
        *   `sub_store_id` (String, optional): e.g., `SS1`
        *   `month` (String, required, format: `YYYY-MM`): e.g., `2024-11`
    *   **Example Request:**
        `GET /api/v1/metrics/monthly-satisfaction?store_id=S1&month=2024-11`
        `GET /api/v1/metrics/monthly-satisfaction?store_id=S1&sub_store_id=SS2&month=2024-11`
    *   **Example Success Response (200 OK):**
        ```json
        [
          {
            "satisfactionMonth": "2024-11-01",
            "storeId": "S1",
            "subStoreId": "SS2",
            "avgMonthlySatisfactionScore": 4.5,
            "numberOfSurveysFact": 20
          }
        ]
        ```
    *   **Possible Error Responses:**
        *   `204 No Content`: If no data found for the given filters.
        *   `400 Bad Request`: If required parameters are missing or invalid format.
        *   `500 Internal Server Error`: For unexpected server-side issues.

2.  **Get Average Survey Response Time:**
    *   **Endpoint:** `GET /api/v1/metrics/average-response-time`
    *   **Query Parameters:** Same as Monthly Satisfaction.
    *   **Example Request:**
        `GET /api/v1/metrics/average-response-time?store_id=S3&month=2024-10`
    *   **Example Success Response (200 OK):**
        ```json
        [
          {
            "responseMonth": "2024-10-01",
            "storeId": "S3",
            "subStoreId": null,
            "monthlyAvgResponseTimeDays": 2.75,
            "totalResponsesForAvgTime": 15
          }
        ]
        ```

3.  **Get Survey Participation Rate:**
    *   **Endpoint:** `GET /api/v1/metrics/participation-rate`
    *   **Query Parameters:** Same as Monthly Satisfaction.
    *   **Example Request:**
        `GET /api/v1/metrics/participation-rate?store_id=S2&sub_store_id=SS4&month=2024-09`
    *   **Example Success Response (200 OK):**
        ```json
        [
          {
            "surveyMonth": "2024-09-01",
            "storeId": "S2",
            "subStoreId": "SS4",
            "surveyResponseCountFact": 50,
            "activeEmployeeCountFact": 100,
            "participationRatePercentage": 50.0
          }
        ]
        ```

**UI Demonstration:**
*   Once the Spring Boot application is running, navigate to `http://localhost:8081/index.html` in a web browser to use the simple UI for querying the metrics.

---

## Code Documentation:

*   **Java Code:** Javadoc comments are included for public classes and methods within the `src/main/java` directory, detailing their functionality, parameters, and return values.
*   **Logging:** SLF4J with Logback is used for logging application events, particularly within the service and controller layers for request tracing and error diagnosis.

---
## Notes on "Expected Behaviours":

*   **Incremental Data Handling & Soft Deletion:** The API reads from mart tables that are rebuilt by DBT. The DBT pipeline handles soft deletion by excluding records flagged in `stg_deleted_records` before metric calculation. The API layer itself does not perform incremental data loading; it queries the current state of the DWH.
*   **Partitioning:** The underlying Snowflake tables, populated by DBT, can be configured with `CLUSTER BY` keys (e.g., on date and store identifiers) to optimize query performance, leveraging Snowflake's micro-partitioning capabilities. This is handled at the DWH/DBT level.
*   **Three Tier Architecture:** The Spring Boot application is structured into:
    1.  **Controller Tier:** Handles HTTP requests and API routing.
    2.  **Service Tier:** Encapsulates business logic for metrics.
    3.  **Repository Tier:** Manages data access to Snowflake.
