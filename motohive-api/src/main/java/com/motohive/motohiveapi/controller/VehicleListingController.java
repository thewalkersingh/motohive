package com.motohive.motohiveapi.controller;

import com.motohive.motohiveapi.dto.ListingSearchCriteria;
import com.motohive.motohiveapi.dto.PageResponse;
import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;
import com.motohive.motohiveapi.service.VehicleListingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
public class VehicleListingController {
	
	private final VehicleListingService listingService;
	
	@PostMapping
	public ResponseEntity<VehicleListingResponse> createListing(@RequestBody VehicleListingRequest request) {
		return ResponseEntity.ok(listingService.createListing(request));
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<VehicleListingResponse> getListingById(@PathVariable Long id) {
		return ResponseEntity.ok(listingService.getListingById(id));
	}
	
	// New Advanced Search Endpoint
	@GetMapping
	public ResponseEntity<PageResponse<VehicleListingResponse>> searchListings(
		@ModelAttribute ListingSearchCriteria criteria,
		@PageableDefault(size = 10) Pageable pageable) {
		
		Page<VehicleListingResponse> page = listingService.searchListings(criteria, pageable);
		
		PageResponse<VehicleListingResponse> response = new PageResponse<>(
			page.getContent(),
			page.getNumber(),
			page.getSize(),
			page.getTotalElements(),
			page.getTotalPages(),
			page.isLast()
		);
		
		return ResponseEntity.ok(response);
	}
	
}