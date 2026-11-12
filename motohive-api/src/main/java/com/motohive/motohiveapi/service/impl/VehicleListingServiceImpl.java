package com.motohive.motohiveapi.service.impl;

import com.motohive.motohiveapi.domain.entity.ListingMedia;
import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.domain.entity.VehicleListing;
import com.motohive.motohiveapi.domain.enums.InspectionStatus;
import com.motohive.motohiveapi.domain.enums.ListingStatus;
import com.motohive.motohiveapi.dto.ListingMediaRequest;
import com.motohive.motohiveapi.dto.ListingSearchCriteria;
import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;
import com.motohive.motohiveapi.mapper.VehicleMapper;
import com.motohive.motohiveapi.repository.UserRepository;
import com.motohive.motohiveapi.repository.VehicleListingRepository;
import com.motohive.motohiveapi.service.VehicleListingService;
import com.motohive.motohiveapi.util.ListingSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class VehicleListingServiceImpl implements VehicleListingService {
	
	private final VehicleListingRepository listingRepository;
	private final UserRepository userRepository;
	
	@Transactional
	public VehicleListingResponse createListing(VehicleListingRequest request) {
		// ... (Keep your existing createListing logic exactly as it is) ...
		User seller =
			userRepository.findById(request.sellerId()).orElseThrow(() -> new RuntimeException("Seller not found"));
		
		VehicleListing listing =
			VehicleListing.builder().seller(seller).title(request.title()).description(request.description())
							  .price(request.price()).make(request.make()).model(request.model())
							  .yearOfManufacture(request.yearOfManufacture()).mileageKm(request.mileageKm())
							  .engineCc(request.engineCc()).condition(request.condition())
							  .listingStatus(ListingStatus.DRAFT) // Created as DRAFT, we will
							  // update to ACTIVE for
							  // testing
							  .inspectionStatus(InspectionStatus.PENDING).build();
		
		if (request.media() != null) {
			for (ListingMediaRequest mediaReq : request.media()) {
				ListingMedia media = ListingMedia.builder().url(mediaReq.url()).mediaType(mediaReq.mediaType())
															.isPrimary(mediaReq.isPrimary() != null && mediaReq.isPrimary())
															.displayOrder(
																mediaReq.displayOrder() != null ? mediaReq.displayOrder() : 0).build();
				listing.addMedia(media);
			}
		}
		VehicleListing saved = listingRepository.save(listing);
		return VehicleMapper.mapToResponse(saved);
	}
	
	@Transactional(readOnly = true)
	public VehicleListingResponse getListingById(Long id) {
		VehicleListing listing =
			listingRepository.findById(id).orElseThrow(() -> new RuntimeException("Listing not " + "found"));
		return VehicleMapper.mapToResponse(listing);
	}
	
	@Transactional(readOnly = true)
	public Page<VehicleListingResponse> searchListings(ListingSearchCriteria criteria, Pageable pageable) {
		// Build dynamic query
		var spec = ListingSpecification.filter(criteria);
		// Execute and map to DTOs
		return listingRepository.findAll(spec, pageable).map(VehicleMapper::mapToResponse);
	}
	
}