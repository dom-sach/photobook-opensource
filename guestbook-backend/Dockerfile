# --- build stage ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -e -DskipTests package spring-boot:repackage


# --- runtime stage ---
FROM eclipse-temurin:21-jre

# ===== Install PostgreSQL =====
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-16 postgresql-client-16 \
    && rm -rf /var/lib/apt/lists/*

# ===== Create users & dirs =====
WORKDIR /app
RUN useradd -ms /bin/bash appuser \
 && mkdir -p /app/uploads \
 && mkdir -p /var/lib/postgresql \
 && chown -R appuser:appuser /app \
 && chown -R postgres:postgres /var/lib/postgresql

# ===== Copy app =====
COPY --from=build /app/target/*.jar /app/app.jar

# ===== Copy entrypoint =====
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENV JAVA_OPTS=""
ENV PORT=8080

ENTRYPOINT ["/entrypoint.sh"]
