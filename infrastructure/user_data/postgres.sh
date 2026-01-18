#!/bin/bash
set -e

dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# Format + mount EBS
# === WAIT FOR EBS ===
DEVICE="/dev/xvdf"

echo "Waiting for EBS device $DEVICE..."
while [ ! -b "$DEVICE" ]; do
  sleep 2
done

echo "EBS device found"

# === FORMAT (only first time) ===
if ! blkid $DEVICE; then
  mkfs -t xfs $DEVICE
fi

mkdir -p /data/postgres
mount $DEVICE /data/postgres
echo "$DEVICE /data/postgres xfs defaults,nofail 0 2" >> /etc/fstab

docker run -d \
  --name postgres \
  --restart always \
  -p 5432:5432 \
  -e POSTGRES_DB=guestbook \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -v /data/postgres:/var/lib/postgresql/data \
  postgres:16
