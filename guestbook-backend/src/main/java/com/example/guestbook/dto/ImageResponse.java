package com.example.guestbook.dto;

import java.time.Instant;

public record ImageResponse(
        Long id,
        String caption,
        Instant uploadTime,
        String url
) {}

