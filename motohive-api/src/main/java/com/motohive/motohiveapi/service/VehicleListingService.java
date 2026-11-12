package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.dto.ListingSearchCriteria;
import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface VehicleListingService {
	
	VehicleListingResponse createListing(VehicleListingRequest request);
	
	VehicleListingResponse getListingById(Long id);
	
	// New method replacing getAllListings
	Page<VehicleListingResponse> searchListings(ListingSearchCriteria criteria, Pageable pageable);
	
}