package com.example.guestbook.service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class CurrentUserService {

    public String getIdentifier(Jwt jwt) {

        log.info(">>> JWT subject: {}", jwt.getSubject());
        log.info(">>> JWT claims keys: {}", jwt.getClaims().keySet());

        String email = jwt.getClaimAsString("email");
        if (email != null && !email.isBlank()) {
            log.info(">>> Using email from token: {}", email);
            return email;
        }

        String username = jwt.getClaimAsString("preferred_username");
        if (username != null && !username.isBlank()) {
            log.info(">>> Using preferred_username from token: {}", username);
            return username;
        }

        log.info(">>> Falling back to subject");
        return jwt.getSubject();
    }
}
