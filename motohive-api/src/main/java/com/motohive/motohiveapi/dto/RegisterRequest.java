package com.motohive.motohiveapi.dto;
import com.motohive.motohiveapi.domain.enums.UserRole;

public record RegisterRequest(String fullName, String email, String password, UserRole role) {

}