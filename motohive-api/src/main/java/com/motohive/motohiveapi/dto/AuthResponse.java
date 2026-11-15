package com.motohive.motohiveapi.dto;
public record AuthResponse(String token, Long userId, String email, String role) {

}