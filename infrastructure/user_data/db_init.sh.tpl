#!/bin/bash
set -e

dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# ===== Format + mount EBS =====
mkfs -t xfs /dev/xvdf || true
mkdir -p /data/postgres
mount /dev/xvdf /data/postgres
echo "/dev/xvdf /data/postgres xfs defaults,nofail 0 2" >> /etc/fstab

# ===== Init SQL for Keycloak =====
mkdir -p /data/initdb

cat <<EOF > /data/initdb/init-keycloak.sql
CREATE DATABASE keycloak;
GRANT ALL PRIVILEGES ON DATABASE keycloak TO ${db_user};
EOF

# ===== Run PostgreSQL container =====
docker run -d \
  --name postgres \
  --restart always \
  -p 5432:5432 \
  -e POSTGRES_DB=${db_name} \
  -e POSTGRES_USER=${db_user} \
  -e POSTGRES_PASSWORD=${db_password} \
  -v /data/postgres:/var/lib/postgresql/data \
  -v /data/initdb:/docker-entrypoint-initdb.d \
  postgres:16
