@echo off

setlocal enabledelayedexpansion

echo Budowanie obrazu backendu...
docker build -t guestbook-backend ..\guestbook-backend
IF ERRORLEVEL 1 EXIT /B 1

echo Logowanie do ECR...
FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO docker login --username AWS --password %%i %ECR_URL%
IF ERRORLEVEL 1 EXIT /B 1

echo Tagowanie obrazu...
docker tag guestbook-backend:latest %ECR_URL%:latest
IF ERRORLEVEL 1 EXIT /B 1

echo Push do ECR...
docker push %ECR_URL%:latest
IF ERRORLEVEL 1 EXIT /B 1

echo Backend image pushed to %ECR_URL%
