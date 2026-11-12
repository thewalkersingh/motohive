package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.MediaType;

public record ListingMediaResponse(Long id, String url, MediaType mediaType, Boolean isPrimary, Integer displayOrder) {

}