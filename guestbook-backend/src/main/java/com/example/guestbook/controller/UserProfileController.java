package com.example.guestbook.controller;

import com.example.guestbook.dto.UserProfileRequest;
import com.example.guestbook.model.UserProfile;
import com.example.guestbook.repository.UserProfileRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
public class UserProfileController {

    private final UserProfileRepository repo;

    public UserProfileController(UserProfileRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public UserProfile getProfile(@AuthenticationPrincipal Jwt jwt) {

        String email = extractUserEmail(jwt);

        return repo.findById(email).orElseGet(() -> {
            UserProfile p = new UserProfile();
            p.setEmail(email);
            p.setBio("");
            p.setFavoriteColor("");
            return repo.save(p);
        });
    }

    @PostMapping
    public UserProfile updateProfile(@RequestBody UserProfileRequest request,
                                     @AuthenticationPrincipal Jwt jwt) {

        String email = extractUserEmail(jwt);

        UserProfile profile = repo.findById(email).orElse(new UserProfile());
        profile.setEmail(email);
        profile.setBio(request.getBio());
        profile.setFavoriteColor(request.getFavoriteColor());

        return repo.save(profile);
    }

    /**
     * Centralne miejsce mapowania Keycloak → aplikacja
     */
    private String extractUserEmail(Jwt jwt) {

        // standard OIDC
        String email = jwt.getClaimAsString("email");

        if (email != null && !email.isBlank()) {
            return email;
        }

        // fallback Keycloak
        String username = jwt.getClaimAsString("preferred_username");
        if (username != null && !username.isBlank()) {
            return username;
        }

        // ostateczny fallback (sub)
        return jwt.getSubject();
    }
}

