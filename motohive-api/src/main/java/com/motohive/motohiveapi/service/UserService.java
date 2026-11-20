package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.dto.UserRequest;
import com.motohive.motohiveapi.dto.UserResponse;
import org.springframework.security.core.userdetails.UserDetailsService;

public interface UserService extends UserDetailsService {
	
	UserResponse createUser(UserRequest request);
	
	UserResponse getUserById(Long id);
	
}