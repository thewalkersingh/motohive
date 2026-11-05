package com.motohive.motohiveapi.controller;

import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;
import com.motohive.motohiveapi.service.VehicleListingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
public class VehicleListingController {
	
	private final VehicleListingService listingService;
	
	@PostMapping
	public ResponseEntity<VehicleListingResponse> createListing(@RequestBody VehicleListingRequest request) {
		return ResponseEntity.ok(listingService.createListing(request));
	}
	
	@GetMapping
	public ResponseEntity<List<VehicleListingResponse>> getAllListings() {
		return ResponseEntity.ok(listingService.getAllListings());
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<VehicleListingResponse> getListingById(@PathVariable UUID id) {
		return ResponseEntity.ok(listingService.getListingById(id));
	}
	
}