package com.rasheed.harri.api.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ParticipationRateDTO {
    private LocalDate surveyMonth;
    private String storeId;
    private String subStoreId;
    private Integer surveyResponseCountFact;
    private Integer activeEmployeeCountFact;
    private Double participationRatePercentage;
}
