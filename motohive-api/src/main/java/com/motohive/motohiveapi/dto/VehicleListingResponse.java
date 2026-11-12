package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.InspectionStatus;
import com.motohive.motohiveapi.domain.enums.ListingStatus;
import com.motohive.motohiveapi.domain.enums.VehicleCondition;

import java.math.BigDecimal;
import java.util.List;

public record VehicleListingResponse(
	Long id,
	String title,
	BigDecimal price,
	String make,
	String model,
	Integer yearOfManufacture,
	Integer engineCc,
	Integer mileageKm,
	VehicleCondition condition,
	ListingStatus listingStatus,
	InspectionStatus inspectionStatus,
	UserResponse seller,
	List<ListingMediaResponse> media
) {

}