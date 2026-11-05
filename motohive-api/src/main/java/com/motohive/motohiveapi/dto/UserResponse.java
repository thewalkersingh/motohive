package com.motohive.motohiveapi.dto;

import com.motohive.motohiveapi.domain.enums.UserRole;
import java.util.UUID;

public record UserResponse(UUID id, String fullName, String email, UserRole role) {

}