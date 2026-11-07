package com.motohive.motohiveapi.service;

import com.motohive.motohiveapi.domain.enums.MediaType;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface FileStorageService {
	
	Map<String, Object> uploadFile(MultipartFile file, MediaType mediaType);
	
	void deleteFile(String publicId);
	
}