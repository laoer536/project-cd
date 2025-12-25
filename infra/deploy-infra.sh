#!/usr/bin/env bash
set -euo pipefail

echo "🗄️ Infra deployment started"

# ------------------------
# Config
# ------------------------
COMPOSE_FILE="infra.compose.yml"
PROJECT_NAME="neo-prod-infra"

# ------------------------
# Sanity checks
# ------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ docker not found"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "❌ docker compose not available"
  exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ $COMPOSE_FILE not found"
  exit 1
fi

# ------------------------
# Deploy infra
# ------------------------
echo "📦 Using compose file: $COMPOSE_FILE"
echo "📛 Compose project name: $PROJECT_NAME"

docker compose \
  -p "$PROJECT_NAME" \
  -f "$COMPOSE_FILE" \
  up -d

# ------------------------
# Post checks (optional but recommended)
# ------------------------
echo "🔍 Infra status:"
docker compose \
  -p "$PROJECT_NAME" \
  -f "$COMPOSE_FILE" \
  ps

echo "✅ Infra ready"
