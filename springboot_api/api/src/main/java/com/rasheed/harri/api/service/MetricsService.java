package com.rasheed.harri.api.service;

import com.rasheed.harri.api.dto.AvgResponseTimeDTO;
import com.rasheed.harri.api.dto.MonthlySatisfactionDTO;
import com.rasheed.harri.api.dto.ParticipationRateDTO;
import com.rasheed.harri.api.repository.MetricsRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Optional;

@Service
public class MetricsService {

    private static final Logger logger = LoggerFactory.getLogger(MetricsService.class);
    private final MetricsRepository metricsRepository;

    @Autowired
    public MetricsService(MetricsRepository metricsRepository) {
        this.metricsRepository = metricsRepository;
    }

    public List<MonthlySatisfactionDTO> getMonthlySatisfaction(String storeId, Optional<String> subStoreId, YearMonth yearMonth) {
        LocalDate monthDate = yearMonth.atDay(1);
        logger.info("Fetching monthly satisfaction for store: {}, sub-store: {}, month: {}", storeId, subStoreId.orElse("N/A"), monthDate);
        return metricsRepository.findMonthlySatisfaction(storeId, subStoreId.orElse(null), monthDate);
    }

    public List<AvgResponseTimeDTO> getAvgResponseTime(String storeId, Optional<String> subStoreId, YearMonth yearMonth) {
        LocalDate monthDate = yearMonth.atDay(1);
        logger.info("Fetching average response time for store: {}, sub-store: {}, month: {}", storeId, subStoreId.orElse("N/A"), monthDate);
        return metricsRepository.findAvgResponseTime(storeId, subStoreId.orElse(null), monthDate);
    }

    public List<ParticipationRateDTO> getParticipationRate(String storeId, Optional<String> subStoreId, YearMonth yearMonth) {
        LocalDate monthDate = yearMonth.atDay(1);
        logger.info("Fetching participation rate for store: {}, sub-store: {}, month: {}", storeId, subStoreId.orElse("N/A"), monthDate);
        return metricsRepository.findParticipationRate(storeId, subStoreId.orElse(null), monthDate);
    }
}