@echo off
setlocal enabledelayedexpansion

echo === Building Prometheus image ===

REM Zakładamy, że CWD = folder infrastructure (bo tak odpala to local-exec)
set PROM_DIR=prometheus

REM --- Sanity checks ---
if not exist prometheus.yml.tpl (
  echo ERROR: prometheus.yml.tpl not found in %CD%
  exit /b 1
)

if not exist %PROM_DIR%\Dockerfile (
  echo ERROR: %PROM_DIR%\Dockerfile not found in %CD%
  exit /b 1
)

REM --- Render prometheus.yml into build context ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "(Get-Content '.\prometheus.yml.tpl' -Raw) -replace '\$\{alb_dns\}', '%ALB_DNS%' | Set-Content '.\%PROM_DIR%\prometheus.yml' -NoNewline"

if errorlevel 1 exit /b 1

REM --- Build image ---
docker build -t guestbook-prometheus .\%PROM_DIR%
if errorlevel 1 exit /b 1

REM --- Login & push ---
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_URL%
if errorlevel 1 exit /b 1

docker tag guestbook-prometheus:latest %ECR_URL%:latest
if errorlevel 1 exit /b 1

docker push %ECR_URL%:latest
if errorlevel 1 exit /b 1

echo === Prometheus image pushed ===
