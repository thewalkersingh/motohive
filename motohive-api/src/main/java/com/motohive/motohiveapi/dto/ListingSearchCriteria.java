package com.motohive.motohiveapi.dto;

import java.math.BigDecimal;

public record ListingSearchCriteria(
	String keyword,       // Searches title, make, model
	String make,          // Exact match for make
	String condition,     // Exact match for condition (e.g., "LIKE_NEW")
	BigDecimal minPrice,
	BigDecimal maxPrice,
	Integer minCc,
	Integer maxCc
) {

}