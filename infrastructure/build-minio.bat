@echo off
echo === Building MinIO init image ===

docker build -t photobook-minio-init .\minio

echo === Logging in to ECR ===
FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO docker login --username AWS --password %%i %ECR_URL%

echo === Tagging image ===
docker tag photobook-minio-init:latest %ECR_URL%:latest

echo === Pushing image ===
docker push %ECR_URL%:latest

echo === MinIO init image pushed ===
