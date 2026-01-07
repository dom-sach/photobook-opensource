package com.example.guestbook.controller;

import com.example.guestbook.dto.ImageResponse;
import com.example.guestbook.model.ImageMetadata;
import com.example.guestbook.repository.ImageMetadataRepository;
import com.example.guestbook.service.CurrentUserService;
import com.example.guestbook.service.ImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/images")
@RequiredArgsConstructor
public class ImageController {

    private final ImageService imageService;
    private final ImageMetadataRepository repo;
    private final CurrentUserService currentUserService;

    @Value("${s3.bucket}")
    private String bucket;

    @Value("${s3.public.base-url}")
    private String publicBaseUrl;

    public String getPublicUrl(String filename) {
        return publicBaseUrl + "/" + bucket + "/" + filename;
    }

    // upload nowego obrazka
    @PostMapping
    public ResponseEntity<?> uploadImage(
            @RequestPart("file") MultipartFile file,
            @RequestPart(value = "caption", required = false) String caption,
            @AuthenticationPrincipal Jwt jwt
    ) {

        System.out.println("=== UPLOAD IMAGE HIT ===");
        System.out.println("file = " + (file != null ? file.getOriginalFilename() : "NULL"));
        System.out.println("file size = " + (file != null ? file.getSize() : "NULL"));
        System.out.println("contentType = " + (file != null ? file.getContentType() : "NULL"));
        System.out.println("caption = " + caption);
        System.out.println("jwt present = " + (jwt != null));

        if (jwt == null) {
            log.error(">>> JWT IS NULL");
            return ResponseEntity.status(401).body("JWT missing");
        }
        try {

            if (caption == null) {
                caption = "";
            }

            String userIdentifier = currentUserService.getIdentifier(jwt);
            log.info(">>> JWT subject: {}", jwt.getSubject());

            ImageMetadata metadata = imageService.upload(file, caption, userIdentifier);

            return ResponseEntity.ok(
                    new ImageResponse(
                            metadata.getId(),
                            metadata.getCaption(),
                            metadata.getUploadTime(),
                            imageService.getPublicUrl(metadata.getFilename())
                    )
            );

        } catch (Exception e) {
            log.error(">>> Upload failed", e);
            return ResponseEntity.badRequest()
                    .body("Błąd podczas uploadu: " + e.getMessage());
        }
    }

    // zwraca listę wszystkich obrazków (metadanych)
    @GetMapping
    public ResponseEntity<List<ImageResponse>> listImages(@AuthenticationPrincipal Jwt jwt) {

        log.info(">>> ENTER GET /api/images");

        if (jwt == null) {
            log.error(">>> JWT IS NULL in GET");
            return ResponseEntity.status(401).build();
        }

        log.info(">>> JWT subject: {}", jwt.getSubject());

        List<ImageMetadata> images = repo.findAllByOrderByUploadTimeDesc();

        log.info(">>> Found {} images", images.size());

        List<ImageResponse> response = images.stream()
                .map(img -> new ImageResponse(
                        img.getId(),
                        img.getCaption(),
                        img.getUploadTime(),
                        imageService.getPublicUrl(img.getFilename())
                ))
                .toList();
        return ResponseEntity.ok(response);
    }

}
