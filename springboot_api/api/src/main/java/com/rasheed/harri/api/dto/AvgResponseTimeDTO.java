package com.rasheed.harri.api.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AvgResponseTimeDTO {
    private LocalDate responseMonth;
    private String storeId;
    private String subStoreId;
    private Double monthlyAvgResponseTimeDays;
    private Integer totalResponsesForAvgTime;
}
