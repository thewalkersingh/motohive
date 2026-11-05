package com.motohive.motohiveapi.domain.entity;

import com.motohive.motohiveapi.domain.enums.InspectionStatus;
import com.motohive.motohiveapi.domain.enums.ListingStatus;
import com.motohive.motohiveapi.domain.enums.VehicleCondition;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "vehicle_listings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VehicleListing extends AbstractAuditingEntity {
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "seller_id", nullable = false)
	private User seller;
	
	private String title;
	
	@Column(columnDefinition = "TEXT")
	private String description;
	
	private BigDecimal price;
	private String make;
	private String model;
	private Integer yearOfManufacture;
	private Integer mileageKm;
	private Integer engineCc;
	
	@Enumerated(EnumType.STRING)
	private VehicleCondition condition;
	
	@Enumerated(EnumType.STRING)
	private ListingStatus listingStatus;
	
	@Enumerated(EnumType.STRING)
	private InspectionStatus inspectionStatus;
	
	@OneToMany(mappedBy = "listing", cascade = CascadeType.ALL, orphanRemoval = true)
	@Builder.Default
	private List<ListingMedia> media = new ArrayList<>();
	
	// Helper method to maintain bidirectional relationship
	public void addMedia(ListingMedia mediaItem) {
		media.add(mediaItem);
		mediaItem.setListing(this);
	}
}