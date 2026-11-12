package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.dto.UserRequest;
import com.motohive.motohiveapi.dto.UserResponse;

public interface UserService {
	
	UserResponse createUser(UserRequest request);
	
	UserResponse getUserById(Long id);
	
}