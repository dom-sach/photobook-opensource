package com.example.guestbook.controller;

import com.example.guestbook.model.ImageMetadata;
import com.example.guestbook.repository.ImageMetadataRepository;
import com.example.guestbook.service.CurrentUserService;
import com.example.guestbook.service.ImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
@Slf4j
@RestController
@RequestMapping("/api/images")
@RequiredArgsConstructor
public class ImageController {

    private final ImageService imageService;
    private final ImageMetadataRepository repo;
    private final CurrentUserService currentUserService;

    // upload nowego obrazka
    @PostMapping
    public ResponseEntity<?> uploadImage(
            @RequestPart("file") MultipartFile file,
            @RequestPart("caption") String caption,
            @AuthenticationPrincipal Jwt jwt
    ) {

        if (jwt == null) {
            log.error(">>> JWT IS NULL");
            return ResponseEntity.status(401).body("JWT missing");
        }
        try {
            String userIdentifier = currentUserService.getIdentifier(jwt);
            log.info(">>> JWT subject: {}", jwt.getSubject());

            ImageMetadata metadata = imageService.upload(file, caption, userIdentifier);
            String url = imageService.getUrl(metadata.getFilename());

            Map<String, Object> response = new HashMap<>();
            response.put("id", metadata.getId());
            response.put("filename", metadata.getFilename());
            response.put("caption", metadata.getCaption());
            response.put("uploadTime", metadata.getUploadTime());
            response.put("url", url);

            log.info(">>> Upload OK, image id={}", metadata.getId());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error(">>> Upload failed", e);
            return ResponseEntity.badRequest()
                    .body("Błąd podczas uploadu: " + e.getMessage());
        }
    }

    // zwraca listę wszystkich obrazków (metadanych)
    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> listImages(@AuthenticationPrincipal Jwt jwt) {

        log.info(">>> ENTER GET /api/images");

        if (jwt == null) {
            log.error(">>> JWT IS NULL in GET");
            return ResponseEntity.status(401).build();
        }

        log.info(">>> JWT subject: {}", jwt.getSubject());

        List<ImageMetadata> images = repo.findAllByOrderByUploadTimeDesc();

        log.info(">>> Found {} images", images.size());

        List<Map<String, Object>> response = images.stream()
                .map(img -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", img.getId());
                    map.put("filename", img.getFilename());
                    map.put("caption", img.getCaption());
                    map.put("uploadTime", img.getUploadTime());
                    map.put("url", imageService.getUrl(img.getFilename()));
                    return map;
                })
                .toList();

        return ResponseEntity.ok(response);
    }

    // pobieranie obrazka po filename
    @GetMapping("/{filename}")
    public ResponseEntity<?> getImage(@PathVariable String filename) {
        log.info(">>> ENTER GET /api/images/{}", filename);
        try {
            return imageService.downloadImage(filename);
        } catch (Exception e) {
            log.error(">>> Download failed for {}", filename, e);
            return ResponseEntity.notFound().build();
        }
    }
}
