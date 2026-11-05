package com.motohive.motohiveapi.domain.entity;

import com.motohive.motohiveapi.domain.enums.MediaType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "listing_media")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ListingMedia extends AbstractAuditingEntity {
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "listing_id", nullable = false)
	private VehicleListing listing;
	
	private String url;
	
	@Enumerated(EnumType.STRING)
	private MediaType mediaType;
	
	private Boolean isPrimary;
	private Integer displayOrder;
	
}