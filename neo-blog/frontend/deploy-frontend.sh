#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Frontend deployment started"

CI_ENV_FILE=".env.frontend.deploy"
COMPOSE_FILE="frontend.compose.yml"

# ------------------------
# Load CI env (simulate CI runner)
# ------------------------
if [ ! -f "$CI_ENV_FILE" ]; then
  echo "❌ $CI_ENV_FILE not found"
  exit 1
fi

echo "📄 Loading CI env: $CI_ENV_FILE"
set -a
source "$CI_ENV_FILE"
set +a

# ------------------------
# Required vars check
# ------------------------
: "${CI_REGISTRY_FRONTEND_IMAGE:?CI_REGISTRY_FRONTEND_IMAGE is required}"

# ------------------------
# Docker registry login
# ------------------------
if [ -n "${CI_REGISTRY:-}" ]; then
  echo "🔐 Logging into registry $CI_REGISTRY"
  echo "$CI_REGISTRY_PASSWORD" | docker login "$CI_REGISTRY" \
    -u "$CI_REGISTRY_USER" \
    --password-stdin
else
  echo "ℹ️ CI_REGISTRY not set, skip docker login"
fi

# ------------------------
# Pull image
# ------------------------
echo "📥 Pulling frontend image..."
docker compose \
  -f "$COMPOSE_FILE" \
  pull frontend

# ------------------------
# Start frontend
# ------------------------
echo "🚀 Starting frontend service..."
docker compose \
  -f "$COMPOSE_FILE" \
  up -d frontend

echo "✅ Frontend deployment complete"
