#!/usr/bin/env bash
set -e

echo "[entrypoint] Starting PostgreSQL..."

PG_VERSION=16
PGDATA="/var/lib/postgresql/data"
DB_NAME="guestbook"

mkdir -p "$PGDATA"
chown -R postgres:postgres /var/lib/postgresql

if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "[entrypoint] Initializing PostgreSQL cluster..."
  su - postgres -c "/usr/lib/postgresql/${PG_VERSION}/bin/initdb -D ${PGDATA}"
  echo "listen_addresses = '127.0.0.1'" >> "$PGDATA/postgresql.conf"
  echo "host all all 127.0.0.1/32 trust" >> "$PGDATA/pg_hba.conf"
fi

su - postgres -c "/usr/lib/postgresql/${PG_VERSION}/bin/pg_ctl -D ${PGDATA} -o \"-p 5432\" -w start"

echo "[entrypoint] Creating database '${DB_NAME}' (if missing)..."
su - postgres -c "createdb ${DB_NAME} || echo '[entrypoint] Database already exists'"

echo "[entrypoint] Starting Spring Boot..."
exec su appuser -c "/opt/java/openjdk/bin/java $JAVA_OPTS -jar /app/app.jar"