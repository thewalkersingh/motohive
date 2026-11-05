package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.VehicleCondition;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record VehicleListingRequest(
	UUID sellerId, String title, String description, BigDecimal price,
	String make, String model, Integer yearOfManufacture, Integer mileageKm, Integer engineCc,
	VehicleCondition condition, List<ListingMediaRequest> media
) {}