#!/bin/bash
set -e

KEYCLOAK_VERSION="21.1.2"
KEYCLOAK_USER="keycloak"
KEYCLOAK_DIR="/opt/keycloak"
KEYCLOAK_REALM="guestbook-frontend"
KEYCLOAK_ADMIN_USER="admin"
KEYCLOAK_ADMIN_PASSWORD="admin123"
KEYCLOAK_PORT="8180"
ALB_DNS="${alb_dns}"

SMTP_USER="${smtp_user}"
SMTP_APP_PASSWORD="${smtp_app_password}"

echo "=== Install system dependencies ==="
dnf update -y
dnf install -y java-17-amazon-corretto

echo "=== Create keycloak user ==="
id $${KEYCLOAK_USER} &>/dev/null || \
  useradd --system --home $${KEYCLOAK_DIR} --shell /sbin/nologin $${KEYCLOAK_USER}

echo "=== Download Keycloak ==="
cd /opt
if [ ! -d "$${KEYCLOAK_DIR}" ]; then
  curl -L -o keycloak.tar.gz \
    https://github.com/keycloak/keycloak/releases/download/$${KEYCLOAK_VERSION}/keycloak-$${KEYCLOAK_VERSION}.tar.gz

  tar -xzf keycloak.tar.gz
  mv keycloak-$${KEYCLOAK_VERSION} keycloak
  chown -R $${KEYCLOAK_USER}:$${KEYCLOAK_USER} $${KEYCLOAK_DIR}
fi

echo "=== Create systemd service ==="
cat <<EOF > /etc/systemd/system/keycloak.service
[Unit]
Description=Keycloak
After=network.target

[Service]
Type=simple
User=$${KEYCLOAK_USER}
Group=$${KEYCLOAK_USER}
Environment=KEYCLOAK_ADMIN=$${KEYCLOAK_ADMIN_USER}
Environment=KEYCLOAK_ADMIN_PASSWORD=$${KEYCLOAK_ADMIN_PASSWORD}
ExecStartPre=$${KEYCLOAK_DIR}/bin/kc.sh build
ExecStart=$${KEYCLOAK_DIR}/bin/kc.sh start-dev \
  --http-enabled=true \
  --http-port=$${KEYCLOAK_PORT} \
  --hostname-strict=false \
  --http-host=0.0.0.0 \
  --hostname=$${ALB_DNS} \
  --health-enabled=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "=== Start Keycloak ==="
systemctl daemon-reload
systemctl enable keycloak
systemctl restart keycloak

echo "=== Wait for Keycloak to be ready ==="
until curl -sf http://localhost:$${KEYCLOAK_PORT}/realms/master > /dev/null; do
  sleep 5
done

echo "=== Login via kcadm ==="
$${KEYCLOAK_DIR}/bin/kcadm.sh config credentials \
  --server http://localhost:$${KEYCLOAK_PORT} \
  --realm master \
  --user $${KEYCLOAK_ADMIN_USER} \
  --password $${KEYCLOAK_ADMIN_PASSWORD}

echo "=== Create realm ==="
  $${KEYCLOAK_DIR}/bin/kcadm.sh create realms \
    --server http://localhost:$${KEYCLOAK_PORT} \
    -s realm=$${KEYCLOAK_REALM} \
    -s enabled=true \
    -s registrationAllowed=true \
    -s registrationEmailAsUsername=true \
    -s verifyEmail=false \
    -s resetPasswordAllowed=false \
    -s rememberMe=true \
    -s loginWithEmailAllowed=true \
    -s passwordPolicy="length(12) and upperCase(1) and lowerCase(1) and digits(1) and specialChars(1) and notUsername" \
    -s smtpServer.host="smtp.gmail.com" \
    -s smtpServer.port="587" \
    -s smtpServer.from=$${SMTP_USER} \
    -s smtpServer.auth=true \
    -s smtpServer.user=$${SMTP_USER} \
    -s smtpServer.password=$${SMTP_APP_PASSWORD} \
    -s smtpServer.starttls=true

echo "=== Create frontend client ==="
$${KEYCLOAK_DIR}/bin/kcadm.sh create clients \
  -r $${KEYCLOAK_REALM} \
  -f - <<EOF
{
  "clientId": "guestbook-frontend",
  "name": "Guestbook Frontend",
  "enabled": true,
  "protocol": "openid-connect",

  "publicClient": true,

  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "bearerOnly": false,

  "attributes": {
    "pkce.code.challenge.method": "S256"
  },

  "redirectUris": [
    "http://$${ALB_DNS}/*"
  ],

  "webOrigins": [
    "http://$${ALB_DNS}"
  ]
}
EOF

echo "=== Completed the keycloak setup task ==="