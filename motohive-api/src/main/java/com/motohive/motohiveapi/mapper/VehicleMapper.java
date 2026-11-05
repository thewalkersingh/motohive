package com.motohive.motohiveapi.mapper;

import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.domain.entity.VehicleListing;
import com.motohive.motohiveapi.dto.ListingMediaResponse;
import com.motohive.motohiveapi.dto.UserResponse;
import com.motohive.motohiveapi.dto.VehicleListingResponse;

import java.util.List;
import java.util.stream.Collectors;

public final class VehicleMapper {
	
	public static VehicleListingResponse mapToResponse(VehicleListing l) {
		List<ListingMediaResponse> mediaResponses = l.getMedia().stream()
																	.map(m -> new ListingMediaResponse(
																		m.getId(),
																		m.getUrl(),
																		m.getMediaType(),
																		m.getIsPrimary(),
																		m.getDisplayOrder())
																	)
																	.collect(Collectors.toList());
		
		User seller = l.getSeller();
		UserResponse sellerRes = new UserResponse(
			seller.getId(),
			seller.getFullName(),
			seller.getEmail(),
			seller.getRole()
		);
		
		return new VehicleListingResponse(
			l.getId(),
			l.getTitle(),
			l.getPrice()
			, l.getMake(),
			l.getModel(),
			l.getYearOfManufacture(),
			l.getEngineCc(),
			l.getMileageKm(),
			l.getCondition(),
			l.getListingStatus(),
			l.getInspectionStatus(),
			sellerRes,
			mediaResponses
		);
	}
	
}