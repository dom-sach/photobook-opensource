package com.example.guestbook.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        // health public
                        .requestMatchers("/health",
                                "/actuator/health",
                                "/swagger-ui/**",
                                "/v3/api-docs/**").permitAll()
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(Customizer.withDefaults())
                );

        return http.build();
    }

    @Bean
    JwtDecoder jwtDecoder() {
        String issuer = System.getenv("OIDC_ISSUER_URI");

        NimbusJwtDecoder jwtDecoder =
                JwtDecoders.fromIssuerLocation(issuer);

        OAuth2TokenValidator<Jwt> azpValidator = jwt -> {
            Object azp = jwt.getClaim("azp");
            if ("guestbook-frontend".equals(azp)) {
                return OAuth2TokenValidatorResult.success();
            }
            return OAuth2TokenValidatorResult.failure(
                    new OAuth2Error("invalid_token", "Invalid authorized party (azp)", null)
            );
        };

        OAuth2TokenValidator<Jwt> withIssuer =
                JwtValidators.createDefaultWithIssuer(issuer);

        jwtDecoder.setJwtValidator(
                new DelegatingOAuth2TokenValidator<>(withIssuer, azpValidator)
        );

        return jwtDecoder;
    }

}

