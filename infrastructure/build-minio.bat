@echo off
echo Building MinIO image...

docker build -t guestbook-minio ./minio

echo Login to ECR...
FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO docker login --username AWS --password %%i %ECR_URL%

docker tag guestbook-minio:latest %ECR_URL%:latest
docker push %ECR_URL%:latest

echo MinIO image pushed.
