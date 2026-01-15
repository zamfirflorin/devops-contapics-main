package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.io.IOException;
import java.util.UUID;

@Service
public class S3Service {

    @Autowired
    private S3Client s3Client;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.region}")
    private String region;

    @Value("${aws.s3.endpoint:}")
    private String endpoint;

    /**
     * Upload a file to S3 and return the file URL
     */
    public String uploadFile(MultipartFile file, String companyUid) throws IOException {
        // Generate unique filename to avoid conflicts
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String key = "photos/" + companyUid + "/" + UUID.randomUUID() + fileExtension;

        // Upload to S3
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .contentType(file.getContentType())
                .build();

        s3Client.putObject(putObjectRequest, RequestBody.fromBytes(file.getBytes()));

        // Return the URL
        return getFileUrl(key);
    }

    /**
     * Generate the URL for a file in S3
     */
    private String getFileUrl(String key) {
        // If using MinIO (custom endpoint), construct URL differently
        if (endpoint != null && !endpoint.isEmpty()) {
            return endpoint + "/" + bucketName + "/" + key;
        }
        // AWS S3 URL format
        return String.format("https://%s.s3.%s.amazonaws.com/%s", bucketName, region, key);
    }

    /**
     * Delete a file from S3
     */
    public void deleteFile(String fileUrl) {
        try {
            // Extract key from URL
            String key = extractKeyFromUrl(fileUrl);

            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            s3Client.deleteObject(deleteObjectRequest);
        } catch (Exception e) {
            // Log error but don't fail the operation
            System.err.println("Failed to delete file from S3: " + e.getMessage());
        }
    }

    /**
     * Extract the S3 key from the full URL
     */
    private String extractKeyFromUrl(String url) {
        // For MinIO URLs: http://endpoint/bucket/key
        if (endpoint != null && !endpoint.isEmpty() && url.startsWith(endpoint)) {
            String pathAfterBucket = url.substring((endpoint + "/" + bucketName + "/").length());
            return pathAfterBucket;
        }

        // For AWS S3 URLs: https://bucket.s3.region.amazonaws.com/photos/rich/filename.ext
        // Extract everything after the domain
        try {
            java.net.URL urlObj = new java.net.URL(url);
            String path = urlObj.getPath();
            // Remove leading slash
            if (path.startsWith("/")) {
                path = path.substring(1);
            }
            return path;
        } catch (Exception e) {
            System.err.println("Failed to parse URL: " + url);
            return url;
        }
    }
}
