package com.motohive.motohiveapi.service.impl;

import com.motohive.motohiveapi.domain.entity.ListingMedia;
import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.domain.entity.VehicleListing;
import com.motohive.motohiveapi.domain.enums.InspectionStatus;
import com.motohive.motohiveapi.domain.enums.ListingStatus;
import com.motohive.motohiveapi.dto.ListingMediaRequest;
import com.motohive.motohiveapi.dto.VehicleListingRequest;
import com.motohive.motohiveapi.dto.VehicleListingResponse;
import com.motohive.motohiveapi.mapper.VehicleMapper;
import com.motohive.motohiveapi.repository.UserRepository;
import com.motohive.motohiveapi.repository.VehicleListingRepository;
import com.motohive.motohiveapi.service.VehicleListingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VehicleListingServiceImpl implements VehicleListingService {
	
	private final VehicleListingRepository listingRepository;
	private final UserRepository userRepository;
	
	@Transactional
	public VehicleListingResponse createListing(VehicleListingRequest request) {
		User seller = userRepository.findById(request.sellerId())
											 .orElseThrow(() -> new RuntimeException("Seller not found"));
		
		VehicleListing listing = VehicleListing.builder()
															.seller(seller)
															.title(request.title())
															.description(request.description())
															.price(request.price())
															.make(request.make())
															.model(request.model())
															.yearOfManufacture(request.yearOfManufacture())
															.mileageKm(request.mileageKm())
															.engineCc(request.engineCc())
															.condition(request.condition())
															.listingStatus(ListingStatus.DRAFT)
															.inspectionStatus(InspectionStatus.PENDING)
															.build();
		
		if (request.media() != null) {
			for (ListingMediaRequest mediaReq : request.media()) {
				ListingMedia media = ListingMedia.builder()
															.url(mediaReq.url())
															.mediaType(mediaReq.mediaType())
															.isPrimary(mediaReq.isPrimary() != null && mediaReq.isPrimary())
															.displayOrder(
																mediaReq.displayOrder() != null ? mediaReq.displayOrder() : 0)
															.build();
				listing.addMedia(media);
			}
		}
		
		VehicleListing saved = listingRepository.save(listing);
		return VehicleMapper.mapToResponse(saved);
	}
	
	@Transactional(readOnly = true)
	public List<VehicleListingResponse> getAllListings() {
		return listingRepository.findAll().stream()
										.map(VehicleMapper::mapToResponse)
										.collect(Collectors.toList());
	}
	
	@Transactional(readOnly = true)
	public VehicleListingResponse getListingById(UUID id) {
		VehicleListing listing = listingRepository.findById(id)
																.orElseThrow(() -> new RuntimeException("Listing not found"));
		return VehicleMapper.mapToResponse(listing);
	}
	
}