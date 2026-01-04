@echo off
setlocal

echo === Build frontend ===
set VITE_BACKEND_URL=%VITE_BACKEND_URL%


if "%AWS_REGION%"=="" (
  echo AWS_REGION not set
  exit /b 1
)

if "%ECR_URL%"=="" (
  echo ECR_URL not set
  exit /b 1
)

if "%VITE_BACKEND_URL%"=="" (
  echo VITE_BACKEND_URL not set
  exit /b 1
)


cd ..\guestbook-frontend

echo Budowanie obrazu frontendu...
docker build ^
	--build-arg VITE_BACKEND_URL=%VITE_BACKEND_URL% ^
	--build-arg VITE_KEYCLOAK_URL=http://<KEYCLOAK_PUBLIC_IP>:8080 ^
    --build-arg VITE_KEYCLOAK_REALM=guestbook ^
    --build-arg VITE_KEYCLOAK_CLIENT_ID=guestbook-frontend ^
	--platform=linux/amd64 ^
	-t guestbook-frontend .

IF ERRORLEVEL 1 EXIT /B 1

echo Logowanie do ECR...
FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO (
  docker login --username AWS --password %%i %ECR_URL%
)

IF ERRORLEVEL 1 EXIT /B 1

echo Tagowanie obrazu...
docker tag guestbook-frontend:latest %ECR_URL%:latest

echo Push do ECR...
docker push %ECR_URL%:latest

IF ERRORLEVEL 1 EXIT /B 1

echo Frontend image pushed to %ECR_URL%
