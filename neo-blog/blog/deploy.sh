#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Frontend deployment started"


# ------------------------
# Resolve script directory (CRITICAL)
# ------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Script dir: $SCRIPT_DIR"

CI_ENV_FILE="$SCRIPT_DIR/.env.local"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

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
: "${CI_TAG:?CI_TAG is required}"
: "${CI_REGISTRY:?CI_REGISTRY is required}"
: "${CI_REGISTRY_USER:?CI_REGISTRY_USER is required}"
: "${CI_REGISTRY_PASSWORD:?CI_REGISTRY_PASSWORD is required}"
: "${CI_REGISTRY_IMAGE:?CI_REGISTRY_IMAGE is required}"
: "${CI_SERVICE:?CI_SERVICE is required}"

echo "🚀 $CI_SERVICE deployment started"

# ------------------------
# Docker registry login
# ------------------------
echo "🔐 Logging into registry $CI_REGISTRY"
echo "$CI_REGISTRY_PASSWORD" | docker login "$CI_REGISTRY" \
  -u "$CI_REGISTRY_USER" \
  --password-stdin

# ------------------------
# Pull image
# ------------------------
echo "📥 Pulling $CI_SERVICE image..."
docker compose \
  -f "$COMPOSE_FILE" \
  pull "$CI_SERVICE"

# ------------------------
# Start frontend
# ------------------------
echo "🚀 Starting $CI_SERVICE service..."
docker compose \
  -f "$COMPOSE_FILE" \
  up -d "$CI_SERVICE"

echo "✅ $CI_SERVICE deployment complete"
