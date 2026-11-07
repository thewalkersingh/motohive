package com.motohive.motohiveapi.controller;

import com.motohive.motohiveapi.domain.enums.MediaType;
import com.motohive.motohiveapi.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/media")
@RequiredArgsConstructor
public class MediaController {
	
	private final FileStorageService fileStorageService;
	
	@PostMapping("/upload")
	public ResponseEntity<Map<String, Object>> uploadFile(
		@RequestParam("file") MultipartFile file,
		@RequestParam("mediaType") MediaType mediaType) {
		
		if (file.isEmpty()) {
			return ResponseEntity.badRequest().body(Map.of("error", "File is empty"));
		}
		
		// Optional: Add file size/type validation here (e.g., max 10MB)
		if (file.getSize() > 10 * 1024 * 1024) {
			return ResponseEntity.badRequest().body(Map.of("error", "File size exceeds 10MB limit"));
		}
		
		Map<String, Object> uploadResult = fileStorageService.uploadFile(file, mediaType);
		return ResponseEntity.ok(uploadResult);
	}
	
}