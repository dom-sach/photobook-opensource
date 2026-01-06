#!/bin/sh
set -e

if [ -z "$MEDIA_BUCKET" ]; then
  echo "ERROR: MEDIA_BUCKET is not set"
  exit 1
fi


echo "=== Waiting for MinIO API..."

# czekamy aż mc będzie mogło się zalogować
until mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" 2>/dev/null; do
  echo "MinIO not ready yet..."
  sleep 2
done

echo "=== MinIO ready"

# create bucket if not exists
mc mb --ignore-existing local/"$MEDIA_BUCKET"

# allow public reads (obrazy)
mc anonymous set public local/"$MEDIA_BUCKET"

echo "=== MinIO bootstrap complete"

wait