package com.rasheed.harri.api.controller;

import com.rasheed.harri.api.dto.AvgResponseTimeDTO;
import com.rasheed.harri.api.dto.MonthlySatisfactionDTO;
import com.rasheed.harri.api.dto.ParticipationRateDTO;
import com.rasheed.harri.api.service.MetricsService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/metrics") // Base path for all endpoints in this controller
public class MetricsController {

    private static final Logger logger = LoggerFactory.getLogger(MetricsController.class);
    private final MetricsService metricsService;

    @Autowired
    public MetricsController(MetricsService metricsService) {
        this.metricsService = metricsService;
    }

    @GetMapping("/monthly-satisfaction")
    public ResponseEntity<List<MonthlySatisfactionDTO>> getMonthlySatisfaction(
            @RequestParam(name = "store_id") String storeId, // store_id is mandatory
            @RequestParam(name = "sub_store_id", required = false) Optional<String> subStoreId,
            @RequestParam(name = "month") @DateTimeFormat(pattern="yyyy-MM") YearMonth month) {


        logger.info("API call: Get monthly satisfaction for store: {}, sub-store: {}, month: {}",
                storeId, subStoreId.orElse("N/A"), month);

        List<MonthlySatisfactionDTO> metrics = metricsService.getMonthlySatisfaction(storeId, subStoreId, month);
        if (metrics.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(metrics);
    }

    @GetMapping("/average-response-time")
    public ResponseEntity<List<AvgResponseTimeDTO>> getAverageResponseTime(
            @RequestParam(name = "store_id") String storeId,
            @RequestParam(name = "sub_store_id", required = false) Optional<String> subStoreId,
            @RequestParam(name = "month") @DateTimeFormat(pattern="yyyy-MM") YearMonth month) {


        logger.info("API call: Get average response time for store: {}, sub-store: {}, month: {}",
                storeId, subStoreId.orElse("N/A"), month);

        List<AvgResponseTimeDTO> metrics = metricsService.getAvgResponseTime(storeId, subStoreId, month);
        if (metrics.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(metrics);
    }

    @GetMapping("/participation-rate")
    public ResponseEntity<List<ParticipationRateDTO>> getParticipationRate(
            @RequestParam(name = "store_id") String storeId,
            @RequestParam(name = "sub_store_id", required = false) Optional<String> subStoreId,
            @RequestParam(name = "month") @DateTimeFormat(pattern="yyyy-MM") YearMonth month) {


        logger.info("API call: Get participation rate for store: {}, sub-store: {}, month: {}",
                storeId, subStoreId.orElse("N/A"), month);

        List<ParticipationRateDTO> metrics = metricsService.getParticipationRate(storeId, subStoreId, month);
        if (metrics.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(metrics);
    }


}