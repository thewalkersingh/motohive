package com.motohive.motohiveapi.service.impl;

import com.motohive.motohiveapi.domain.entity.User;
import com.motohive.motohiveapi.domain.enums.UserRole;
import com.motohive.motohiveapi.dto.AuthRequest;
import com.motohive.motohiveapi.dto.AuthResponse;
import com.motohive.motohiveapi.dto.RegisterRequest;
import com.motohive.motohiveapi.repository.UserRepository;
import com.motohive.motohiveapi.security.JwtService;
import com.motohive.motohiveapi.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
	
	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final AuthenticationManager authenticationManager;
	
	public AuthResponse register(RegisterRequest request) {
		User user = User.builder()
							 .fullName(request.fullName())
							 .email(request.email())
							 .password(passwordEncoder.encode(request.password()))
							 .role(request.role() != null ? request.role() : UserRole.BUYER)
							 .build();
		userRepository.save(user);
		
		String jwtToken = jwtService.generateToken(user);
		return new AuthResponse(jwtToken, user.getId(), user.getEmail(), user.getRole().name());
	}
	
	public AuthResponse authenticate(AuthRequest request) {
		authenticationManager.authenticate(
			new UsernamePasswordAuthenticationToken(request.email(), request.password())
		);
		User user = userRepository.findByEmail(request.email())
										  .orElseThrow(() -> new RuntimeException("User not found"));
		String jwtToken = jwtService.generateToken(user);
		return new AuthResponse(jwtToken, user.getId(), user.getEmail(), user.getRole().name());
	}
	
}