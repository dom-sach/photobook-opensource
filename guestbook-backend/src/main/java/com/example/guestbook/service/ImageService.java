package com.example.guestbook.service;

import com.example.guestbook.model.ImageMetadata;
import com.example.guestbook.repository.ImageMetadataRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;

@Slf4j
@Service
@RequiredArgsConstructor
public class ImageService {

    private final AmazonS3 amazonS3;
    private final ImageMetadataRepository repo;

    @Value("${s3.bucket}")
    private String bucket;

    @Value("${s3.public.base-url}")
    private String publicBaseUrl;

    public String getPublicUrl(String filename) {
        return publicBaseUrl + "/" + bucket + "/" + filename;
    }

    @PostConstruct
    public void testMinioConnection() {
        log.info("[ImageService] bucket={}, publicBaseUrl={}", bucket, publicBaseUrl);
    }


    // upload obrazu
    public ImageMetadata upload(MultipartFile file, String caption, String email) throws IOException {

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Plik jest pusty");
        }

        String originalName = file.getOriginalFilename();
        System.out.println("[ImageService] Mam plik do wyslania: " + originalName);
        String filename = UUID.randomUUID() +
                (originalName != null ? "-" + originalName : "");


        System.out.println("[ImageService] Bede wysylac do S3 bucket: " + bucket );
        ObjectMetadata meta = new ObjectMetadata();
        meta.setContentLength(file.getSize());
        meta.setContentType(file.getContentType());

        amazonS3.putObject(bucket, filename, file.getInputStream(), meta);
        System.out.println("[ImageService] Wyslalem plik do S3 bucket: " + bucket + " i file: " + filename);

        ImageMetadata metadata = new ImageMetadata();
        metadata.setFilename(filename);
        metadata.setCaption(caption != null ? caption : "");
        metadata.setUploaderEmail(email);
        metadata.setUploadTime(Instant.now());

        return repo.save(metadata);
    }

    public List<ImageMetadata> listAll() {
        return repo.findAllByOrderByUploadTimeDesc();
    }

//    public String getUrl(String filename) {
//        return amazonS3.getUrl(bucket, filename).toString();
//    }

    // pobieranie obrazu
    public ResponseEntity<Resource> downloadImage(String filename) throws MalformedURLException {

        URL url = amazonS3.getUrl(bucket, filename);
        System.out.println("[ImageService] Pobieram Image z bucket: " + bucket + " i file: " + filename);
        Resource resource = new UrlResource(url);

        if (!resource.exists() || !resource.isReadable()) {
            System.out.println("[ImageService] Nie można odczytać pliku: " + filename);
            throw new RuntimeException("Nie można odczytać pliku");
        }

        return ResponseEntity.ok()
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + filename + "\""
                )
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }
}
