package com.motohive.motohiveapi.specification;

import com.motohive.motohiveapi.domain.entity.VehicleListing;
import com.motohive.motohiveapi.domain.enums.ListingStatus;
import com.motohive.motohiveapi.dto.ListingSearchCriteria;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public final class ListingSpecification {
	
	public static Specification<VehicleListing> filter(ListingSearchCriteria criteria) {
		return (root, query, cb) -> {
			List<Predicate> predicates = new ArrayList<>();
			
			// 1. Keyword Search (Title, Make, Model)
			if (criteria.keyword() != null && !criteria.keyword().isBlank()) {
				String pattern = "%" + criteria.keyword().toLowerCase() + "%";
				predicates.add(cb.or(
					cb.like(cb.lower(root.get("title")), pattern),
					cb.like(cb.lower(root.get("make")), pattern),
					cb.like(cb.lower(root.get("model")), pattern)
				));
			}
			
			// 2. Exact Filters
			if (criteria.make() != null && !criteria.make().isBlank()) {
				predicates.add(cb.equal(cb.lower(root.get("make")), criteria.make().toLowerCase()));
			}
			
			if (criteria.condition() != null && !criteria.condition().isBlank()) {
				predicates.add(cb.equal(root.get("condition"), criteria.condition()));
			}
			
			// 3. Range Filters
			if (criteria.minPrice() != null) {
				predicates.add(cb.greaterThanOrEqualTo(root.get("price"), criteria.minPrice()));
			}
			if (criteria.maxPrice() != null) {
				predicates.add(cb.lessThanOrEqualTo(root.get("price"), criteria.maxPrice()));
			}
			if (criteria.minCc() != null) {
				predicates.add(cb.greaterThanOrEqualTo(root.get("engineCc"), criteria.minCc()));
			}
			if (criteria.maxCc() != null) {
				predicates.add(cb.lessThanOrEqualTo(root.get("engineCc"), criteria.maxCc()));
			}
			
			// 4. Default: Only show ACTIVE listings for public search
			predicates.add(cb.equal(root.get("listingStatus"), ListingStatus.ACTIVE));
			
			return cb.and(predicates.toArray(new Predicate[0]));
		};
	}
	
}