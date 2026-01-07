#!/bin/sh
set -eu

: "${S3_ACCESS_KEY:?missing}"
: "${S3_SECRET_KEY:?missing}"
: "${MEDIA_BUCKET:?missing}"

echo "Waiting for MinIO..."
until mc alias set local http://localhost:9000 "$S3_ACCESS_KEY" "$S3_SECRET_KEY"; do
  sleep 2
done

echo "Creating bucket $MEDIA_BUCKET (if not exists)"
#mc mb local/"$MEDIA_BUCKET" || true
#mc anonymous set download local/"$MEDIA_BUCKET"

mc mb --ignore-existing local/"$MEDIA_BUCKET"
mc anonymous set download local/"$MEDIA_BUCKET"

echo "MinIO init done"
