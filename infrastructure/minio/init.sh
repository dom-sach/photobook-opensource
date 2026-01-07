#!/bin/sh
set -eu

: "${MINIO_ROOT_USER:?missing}"
: "${MINIO_ROOT_PASSWORD:?missing}"
: "${MEDIA_BUCKET:?missing}"

echo "Starting MinIO server..."

# Start serwera w tle
minio server /data \
  --address ":9000" \
  --console-address ":9001" &

MINIO_PID=$!

echo "Waiting for MinIO API..."
until mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
  sleep 2
done

echo "Creating bucket: $MEDIA_BUCKET"
mc mb --ignore-existing local/"$MEDIA_BUCKET"
mc anonymous set download local/"$MEDIA_BUCKET"

echo "MinIO ready"

# Przejmij PID 1 (ważne dla ECS)
wait $MINIO_PID

