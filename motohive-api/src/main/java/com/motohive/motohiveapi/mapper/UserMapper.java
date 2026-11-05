package com.motohive.motohiveapi.mapper;

import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.dto.UserResponse;

public final class UserMapper {
	
	public static UserResponse mapToResponse(User u) {
		UserResponse response = new UserResponse(u.getId(), u.getFullName(), u.getEmail(), u.getRole());
		return response;
	}
	
}