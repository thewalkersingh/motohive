package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;

import java.util.List;
import java.util.UUID;

public interface VehicleListingService {
	
	VehicleListingResponse createListing(VehicleListingRequest request);
	
	List<VehicleListingResponse> getAllListings();
	
	VehicleListingResponse getListingById(UUID id);
	
}