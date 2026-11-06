package com.motohive.motohiveapi.repository;

import com.motohive.motohiveapi.domain.entity.VehicleListing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.UUID;

public interface VehicleListingRepository extends JpaRepository<VehicleListing, UUID>,
																	  JpaSpecificationExecutor<VehicleListing> {
	
}