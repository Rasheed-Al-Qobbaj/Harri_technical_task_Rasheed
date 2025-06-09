package com.rasheed.harri.api.repository;

import com.rasheed.harri.api.dto.AvgResponseTimeDTO;
import com.rasheed.harri.api.dto.MonthlySatisfactionDTO;
import com.rasheed.harri.api.dto.ParticipationRateDTO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class MetricsRepository {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public MetricsRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // --- RowMappers (to map ResultSet rows to DTOs) ---
    private static final class MonthlySatisfactionRowMapper implements RowMapper<MonthlySatisfactionDTO> {
        @Override
        public MonthlySatisfactionDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new MonthlySatisfactionDTO(
                    rs.getObject("satisfaction_month", LocalDate.class),
                    rs.getString("store_business_key"),
                    rs.getString("sub_store_business_key"),
                    rs.getDouble("avg_monthly_satisfaction_score"),
                    rs.getInt("number_of_surveys_fact")
            );
        }
    }

    private static final class AvgResponseTimeRowMapper implements RowMapper<AvgResponseTimeDTO> {
        @Override
        public AvgResponseTimeDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new AvgResponseTimeDTO(
                    rs.getObject("response_month", LocalDate.class),
                    rs.getString("store_business_key"),
                    rs.getString("sub_store_business_key"),
                    rs.getDouble("monthly_avg_response_time_days"),
                    rs.getInt("total_responses_for_avg_time")
            );
        }
    }

    private static final class ParticipationRateRowMapper implements RowMapper<ParticipationRateDTO> {
        @Override
        public ParticipationRateDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new ParticipationRateDTO(
                    rs.getObject("survey_month", LocalDate.class),
                    rs.getString("store_business_key"),
                    rs.getString("sub_store_business_key"),
                    rs.getInt("survey_response_count_fact"),
                    rs.getInt("active_employee_count_fact"),
                    rs.getDouble("participation_rate_percentage")
            );
        }
    }


    // --- Query Methods ---
    public List<MonthlySatisfactionDTO> findMonthlySatisfaction(String storeId, String subStoreId, LocalDate month) {

        String sql = "SELECT satisfaction_month, store_business_key, sub_store_business_key, " +
                "avg_monthly_satisfaction_score, number_of_surveys_fact " +
                "FROM HARRI_ANALYTICS_DB.DBT_STAGING_AND_MARTS_MARTS.fct_monthly_satisfaction " +
                "WHERE store_business_key = ? AND satisfaction_month = ?";

        List<Object> params = new ArrayList<>();
        params.add(storeId);
        params.add(month);

        if (subStoreId != null && !subStoreId.trim().isEmpty() && !subStoreId.equals("MISSING_SUB_STORE_KEY")) {
            sql += " AND sub_store_business_key = ?";
            params.add(subStoreId);
        } else {
            sql += " AND sub_store_business_key IS 'MISSING_SUB_STORE_KEY'";
        }
        return jdbcTemplate.query(sql, params.toArray(), new MonthlySatisfactionRowMapper());
    }


    public List<AvgResponseTimeDTO> findAvgResponseTime(String storeId, String subStoreId, LocalDate month) {
        String sql = "SELECT response_month, store_business_key, sub_store_business_key, " +
                "monthly_avg_response_time_days, total_responses_for_avg_time " +
                "FROM HARRI_ANALYTICS_DB.MARTS.fct_avg_response_time " +
                "WHERE store_business_key = ? AND response_month = ?";
        List<Object> params = new ArrayList<>();
        params.add(storeId);
        params.add(month);

        if (subStoreId != null && !subStoreId.trim().isEmpty() && !subStoreId.equals("MISSING_SUB_STORE_KEY")) {
            sql += " AND sub_store_business_key = ?";
            params.add(subStoreId);
        } else {
            sql += " AND sub_store_business_key IS 'MISSING_SUB_STORE_KEY'";
        }
        return jdbcTemplate.query(sql, params.toArray(), new AvgResponseTimeRowMapper());
    }


    public List<ParticipationRateDTO> findParticipationRate(String storeId, String subStoreId, LocalDate month) {
        String sql = "SELECT survey_month, store_business_key, sub_store_business_key, " +
                "survey_response_count_fact, active_employee_count_fact, participation_rate_percentage " +
                "FROM HARRI_ANALYTICS_DB.MARTS.fct_participation_rate " +
                "WHERE store_business_key = ? AND survey_month = ?";
        List<Object> params = new ArrayList<>();
        params.add(storeId);
        params.add(month);

        if (subStoreId != null && !subStoreId.trim().isEmpty() && !subStoreId.equals("MISSING_SUB_STORE_KEY")) {
            sql += " AND sub_store_business_key = ?";
            params.add(subStoreId);
        } else {
            sql += " AND sub_store_business_key IS 'MISSING_SUB_STORE_KEY'";
        }
        return jdbcTemplate.query(sql, params.toArray(), new ParticipationRateRowMapper());
    }
}