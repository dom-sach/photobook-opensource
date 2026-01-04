package com.example.guestbook.controller;

import com.example.guestbook.dto.AddCommentRequest;
import com.example.guestbook.dto.CommentResponse;
import com.example.guestbook.model.Comment;
import com.example.guestbook.service.CommentService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import com.example.guestbook.service.CurrentUserService;

import java.util.List;

@RestController
@RequestMapping("/api/images/{imageId}/comments")
public class CommentController {

    private final CommentService service;
    private final CurrentUserService currentUserService;

    public CommentController(CommentService service, CurrentUserService currentUserService) {
        this.service = service;
        this.currentUserService = currentUserService;
    }

    // pobranie komentarzy do obrazka
    @GetMapping
    public List<CommentResponse> getComments(@PathVariable("imageId") String imageId) {

        List<Comment> comments = service.getCommentsForImage(imageId);

        return comments.stream()
                .map(c -> new CommentResponse(
                        c.getId(),
                        c.getText(),
                        c.getAuthorEmail(),
                        c.getCreatedAt()
                ))
                .toList();
    }

    // dodanie komentarza
    @PostMapping
    public CommentResponse addComment(
            @PathVariable("imageId") String imageId,
            @RequestBody AddCommentRequest request,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String author = currentUserService.getIdentifier(jwt);

        Comment saved = service.addComment(imageId, request.text, author);

        return new CommentResponse(
                saved.getId(),
                saved.getText(),
                saved.getAuthorEmail(),
                saved.getCreatedAt()
        );
    }

    private String extractUserIdentifier(Jwt jwt) {

        String email = jwt.getClaimAsString("email");
        if (email != null && !email.isBlank()) {
            return email;
        }

        String username = jwt.getClaimAsString("preferred_username");
        if (username != null && !username.isBlank()) {
            return username;
        }

        return jwt.getSubject();
    }
}

