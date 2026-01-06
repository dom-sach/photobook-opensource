package com.example.guestbook.config;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

@Configuration
public class S3Config {

    @Value("${s3.endpoint}")
    private String endpoint;

    @Value("${s3.access.key}")
    private String accessKey;

    @Value("${s3.secret.key}")
    private String secretKey;

    @Value("${s3.bucket}")
    private String bucket;

    @PostConstruct
    public void validateConfig() {
        if (bucket == null || bucket.isBlank()) {
            throw new IllegalStateException("S3 bucket name is not configured");
        }
    }

    @Bean
    public AmazonS3 amazonS3() {
        BasicAWSCredentials creds =
                new BasicAWSCredentials(accessKey, secretKey);

        System.out.println("Setting up endpoint  = " + endpoint);
        System.out.println("Setting up the bucket = " + bucket);
        System.out.println("Setting up secret key = " + secretKey);
        System.out.println("Setting up access key  = " + accessKey);

        return AmazonS3ClientBuilder.standard()
                .withEndpointConfiguration(
                        new AwsClientBuilder.EndpointConfiguration(
                                endpoint, "us-east-1"
                        )
                )
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .withPathStyleAccessEnabled(true)
                .build();
    }
}
