#!/usr/bin/env bash
set -euo pipefail

echo "🗄️ Infra deployment started"

COMPOSE_FILE="infra.compose.yml"
PROJECT_NAME="neo-blog-infra"

docker compose \
  -p "$PROJECT_NAME" \
  -f "$COMPOSE_FILE" \
  up -d

echo "✅ Infra ready"