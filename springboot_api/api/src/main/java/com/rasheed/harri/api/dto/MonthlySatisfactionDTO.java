package com.rasheed.harri.api.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MonthlySatisfactionDTO {
    private LocalDate satisfactionMonth;
    private String storeId;          // Business key from fct_ table
    private String subStoreId;       // Business key from fct_ table
    private Double avgMonthlySatisfactionScore;
    private Integer numberOfSurveysFact;
}
