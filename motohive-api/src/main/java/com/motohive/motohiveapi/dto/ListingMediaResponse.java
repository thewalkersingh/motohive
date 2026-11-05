package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.MediaType;

import java.util.UUID;

public record ListingMediaResponse(
	UUID id, String url,
	MediaType mediaType,
	Boolean isPrimary,
	Integer displayOrder) {
	
}