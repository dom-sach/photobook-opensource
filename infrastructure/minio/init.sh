#!/bin/sh
set -eu

if [ -z "$MEDIA_BUCKET" ]; then
  echo "ERROR: MEDIA_BUCKET is not set"
  exit 1
fi

: "${S3_ACCESS_KEY:?missing}"
: "${S3_SECRET_KEY:?missing}"
: "${MEDIA_BUCKET:?missing}"

echo "Waiting for MinIO..."
until mc alias set local http://minio:9000 "$S3_ACCESS_KEY" "$S3_SECRET_KEY"; do
  sleep 2
done

echo "Creating bucket $MEDIA_BUCKET (if not exists)"
#mc mb local/"$MEDIA_BUCKET" || true
#mc anonymous set download local/"$MEDIA_BUCKET"

mc mb --ignore-existing local/"$MEDIA_BUCKET"
mc anonymous set download local/"$MEDIA_BUCKET"

echo "MinIO init done"
