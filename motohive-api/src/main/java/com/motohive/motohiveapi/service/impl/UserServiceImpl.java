package com.motohive.motohiveapi.service.impl;

import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.dto.UserRequest;
import com.motohive.motohiveapi.dto.UserResponse;
import com.motohive.motohiveapi.mapper.UserMapper;
import com.motohive.motohiveapi.repository.UserRepository;
import com.motohive.motohiveapi.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
	
	private final UserRepository userRepository;
	
	public UserResponse createUser(UserRequest request) {
		User user = User.builder()
							 .fullName(request.fullName())
							 .email(request.email())
							 .role(request.role())
							 .build();
		User saved = userRepository.save(user);
		return UserMapper.mapToResponse(saved);
	}
	
	public UserResponse getUserById(UUID id) {
		return UserMapper.mapToResponse(userRepository.findById(id)
																	 .orElseThrow(() -> new RuntimeException("User not found")));
	}
	
}