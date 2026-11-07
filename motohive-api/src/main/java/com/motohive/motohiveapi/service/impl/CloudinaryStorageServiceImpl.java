package com.motohive.motohiveapi.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.motohive.motohiveapi.domain.enums.MediaType;
import com.motohive.motohiveapi.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class CloudinaryStorageServiceImpl implements FileStorageService {
	
	private final Cloudinary cloudinary;
	
	@Value("${cloudinary.upload-folder}")
	private String uploadFolder;
	
	@Override
	public Map<String, Object> uploadFile(MultipartFile file, MediaType mediaType) {
		try {
			// Determine Cloudinary resource type based on our MediaType
			String resourceType = (mediaType == MediaType.VIDEO) ? "video" : "raw"; // 'raw' is used for PDFs/docs
			
			Map<?, ?> uploadResult = cloudinary.uploader().upload(
				file.getBytes(),
				ObjectUtils.asMap(
					"folder", uploadFolder,
					"resource_type", resourceType
				)
			);
			
			return Map.of(
				"url", uploadResult.get("secure_url"),
				"publicId", uploadResult.get("public_id"),
				"mediaType", mediaType.name()
			);
		} catch (Exception e) {
			throw new RuntimeException("Failed to upload file to Cloudinary", e);
		}
	}
	
	@Override
	public void deleteFile(String publicId) {
		try {
			cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
		} catch (Exception e) {
			// Log error but don't fail the main transaction if deletion fails
			System.err.println("Failed to delete file from Cloudinary: " + publicId);
		}
	}
	
}