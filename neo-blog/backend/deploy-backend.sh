#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Backend deployment started (local CI simulation)"

ENV_FILE=".env.backend.deploy"
COMPOSE_FILE="backend.compose.yml"

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
: "${CI_BACKEND_IMAGE:?CI_BACKEND_IMAGE is required}"
: "${BACKEND_MIGRATE_IMAGE:?BACKEND_MIGRATE_IMAGE is required}"
: "${BACKEND_IMAGE_TAG:?BACKEND_IMAGE_TAG is required}"
: "${MIGRATE_IMAGE_TAG:?MIGRATE_IMAGE_TAG is required}"

# ------------------------
# Docker registry login
# ------------------------
if [ -n "${CI_REGISTRY:-}" ]; then
  echo "🔐 Logging into registry $CI_REGISTRY"
  echo "$CI_REGISTRY_PASSWORD" | docker login "$CI_REGISTRY" \
    -u "$CI_REGISTRY_USER" \
    --password-stdin
fi

# ------------------------
# Pull images
# ------------------------
echo "📥 Pulling backend images..."
docker compose -f "$COMPOSE_FILE" pull

# ------------------------
# Run migration
# ------------------------
echo "🗄️ Running database migration..."
docker compose \
  --env-file "$ENV_FILE" \
  -f "$COMPOSE_FILE" \
  run --rm migrate

# ------------------------
# Start backend
# ------------------------
echo "🚀 Starting backend service..."
docker compose \
  --env-file "$ENV_FILE" \
  -f "$COMPOSE_FILE" \
  up -d backend

echo "✅ Backend deployment complete"
