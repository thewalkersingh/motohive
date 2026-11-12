package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.UserRole;

public record UserResponse(Long id, String fullName, String email, UserRole role) {

}