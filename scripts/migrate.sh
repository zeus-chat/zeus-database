#!/usr/bin/env bash
# Run Liquibase against a PostgreSQL database using the official Docker image.
#
# Usage:   ./scripts/migrate.sh [liquibase command and options]     (default: update)
#   ./scripts/migrate.sh                              apply every pending migration
#   ./scripts/migrate.sh validate                     check the changelog
#   ./scripts/migrate.sh status                       list pending changesets
#   ./scripts/migrate.sh rollback-count --count=1     revert the last changeset
# Config:  reads .env (see .env.example): DB_URL, DB_USER, DB_PASSWORD, CONTEXTS.
set -euo pipefail
export MSYS_NO_PATHCONV=1   # Git Bash on Windows: do not rewrite the volume path

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT/.env" ]; then set -a; . "$ROOT/.env"; set +a; fi

: "${DB_URL:=jdbc:postgresql://host.docker.internal:5432/zeus}"
: "${DB_USER:=zeus}"
: "${DB_PASSWORD:?DB_PASSWORD is required (set it in .env, never commit it)}"
: "${CONTEXTS:=dev}"
LIQUIBASE_IMAGE="${LIQUIBASE_IMAGE:-liquibase/liquibase:4.33.0}"

if [ "$#" -eq 0 ]; then set -- update; fi

exec docker run --rm -v "$ROOT:/liquibase/changelog" "$LIQUIBASE_IMAGE" \
  --search-path=/liquibase/changelog \
  --changelog-file=db.changelog-master.yaml \
  --url="$DB_URL" --username="$DB_USER" --password="$DB_PASSWORD" \
  --contexts="$CONTEXTS" \
  "$@"
