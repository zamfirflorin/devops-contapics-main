package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/photos")
public class PhotoController {
    @Autowired
    private PhotoRepository photoRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private S3Service s3Service;

    @Value("${ocr.service.url:http://localhost:5001}")
    private String ocrServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    @GetMapping
    public List<Photo> getPhotos(@AuthenticationPrincipal User user) {
        if (user.getCompany() == null) return List.of();
        return photoRepository.findByCompany_Id(user.getCompany().getId());
    }

    @PostMapping
    public ResponseEntity<?> uploadPhoto(@AuthenticationPrincipal User user, @RequestParam("file") MultipartFile file) {
        if (user.getCompany() == null) return ResponseEntity.badRequest().body("User has no company");

        try {
            // Upload file to S3
            String s3Url = s3Service.uploadFile(file, user.getCompany().getUid());

            // Save photo metadata to database
            Photo photo = new Photo();
            photo.setUrl(s3Url);
            photo.setUploadedBy(user);
            photo.setCompany(user.getCompany());
            photoRepository.save(photo);

            return ResponseEntity.ok(photo);
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Failed to upload file: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePhoto(@AuthenticationPrincipal User user, @PathVariable Long id) {
        // Find the photo
        Photo photo = photoRepository.findById(id).orElse(null);
        if (photo == null) {
            return ResponseEntity.notFound().build();
        }

        // Check if user has permission to delete (same company)
        if (user.getCompany() == null || !photo.getCompany().getId().equals(user.getCompany().getId())) {
            return ResponseEntity.status(403).body("Forbidden: You don't have permission to delete this photo");
        }

        // Delete from S3
        s3Service.deleteFile(photo.getUrl());

        // Delete from database
        photoRepository.delete(photo);

        return ResponseEntity.ok().body("Photo deleted successfully");
    }

    @PostMapping("/{id}/ocr")
    public ResponseEntity<?> performOcr(@AuthenticationPrincipal User user, @PathVariable Long id) {
        // Find the photo
        Photo photo = photoRepository.findById(id).orElse(null);
        if (photo == null) {
            return ResponseEntity.notFound().build();
        }

        // Check if user has permission to access (same company)
        if (user.getCompany() == null || !photo.getCompany().getId().equals(user.getCompany().getId())) {
            return ResponseEntity.status(403).body("Forbidden: You don't have permission to access this photo");
        }

        try {
            // Prepare request to OCR service
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, String> requestBody = new HashMap<>();
            requestBody.put("s3_url", photo.getUrl());

            HttpEntity<Map<String, String>> request = new HttpEntity<>(requestBody, headers);

            // Call OCR service
            String ocrEndpoint = ocrServiceUrl + "/ocr";
            ResponseEntity<Map> response = restTemplate.postForEntity(ocrEndpoint, request, Map.class);

            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("OCR processing failed: " + e.getMessage());
        }
    }
}
