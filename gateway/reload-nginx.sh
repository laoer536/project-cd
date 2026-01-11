#!/bin/sh

set -e

GATEWAY_CONTAINER="platform-gateway"

echo "[host] checking nginx config in gateway..."
docker exec "$GATEWAY_CONTAINER" nginx -t

echo "[host] reloading nginx in gateway..."
docker exec "$GATEWAY_CONTAINER" nginx -s reload

echo "[host] gateway nginx reload completed."
