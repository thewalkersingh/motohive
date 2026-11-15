package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.dto.AuthRequest;
import com.motohive.motohiveapi.dto.AuthResponse;
import com.motohive.motohiveapi.dto.RegisterRequest;

public interface AuthService {
	
	AuthResponse register(RegisterRequest request);
	
	AuthResponse authenticate(AuthRequest request);
	
}