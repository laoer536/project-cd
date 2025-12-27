#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Backend deployment started (local CI simulation)"

ENV_FILE=".env.backend.deploy"
BACKEND_COMPOSE_FILE="blog-api.backend.compose.yml"
MIGRATE_COMPOSE_FILE="migrate/blog-api.migrate.compose.yml"

# ------------------------
# Load CI env (simulate GitLab CI)
# ------------------------
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ $ENV_FILE not found"
  exit 1
fi

echo "📄 Loading env: $ENV_FILE"
set -a
source "$ENV_FILE"
set +a

# ------------------------
# Required vars check
# ------------------------
: "${CI_REGISTRY:?CI_REGISTRY is required}"
: "${CI_PROJECT:?CI_PROJECT is required}"
: "${CI_SERVICE:?CI_SERVICE is required}"
: "${CI_TAG:?CI_TAG is required}"
: "${CI_MIGRATE_SERVICE:?CI_MIGRATE_SERVICE is required}"


# ------------------------
# Docker registry login
# ------------------------
echo "🔐 Logging into registry $CI_REGISTRY"
echo "$CI_REGISTRY_PASSWORD" | docker login "$CI_REGISTRY" \
  -u "$CI_REGISTRY_USER" \
  --password-stdin

# ------------------------
# Pull images
# ------------------------
echo "📥 Pulling images..."
docker compose -f "$BACKEND_COMPOSE_FILE" pull
docker compose -f "$MIGRATE_COMPOSE_FILE" pull

# ------------------------
# Run migration
# ------------------------
echo "🗄️ Running database migration..."
docker compose \
  --env-file "$ENV_FILE" \
  -f "$MIGRATE_COMPOSE_FILE" \
  run --rm "$CI_MIGRATE_SERVICE"

# ------------------------
# Start backend
# ------------------------
echo "🚀 Starting $CI_SERVICE service..."
docker compose \
  --env-file "$ENV_FILE" \
  -f "$BACKEND_COMPOSE_FILE" \
  up -d "$CI_SERVICE"

echo "✅ $CI_SERVICE deployment complete"
