@echo off
echo === Building Grafana image ===

docker build -t guestbook-grafana ./grafana
IF ERRORLEVEL 1 EXIT /B 1

echo Logging to ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_URL%
IF ERRORLEVEL 1 EXIT /B 1

docker tag guestbook-grafana:latest %ECR_URL%:latest
IF ERRORLEVEL 1 EXIT /B 1

docker push %ECR_URL%:latest
IF ERRORLEVEL 1 EXIT /B 1
