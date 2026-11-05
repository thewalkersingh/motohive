package com.motohive.motohiveapi.dto;
import com.motohive.motohiveapi.domain.enums.UserRole;

public record UserRequest(String fullName, String email, UserRole role) {

}