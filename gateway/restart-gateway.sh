#!/bin/sh

set -e

# ===============================
# 配置部分
# ===============================
GATEWAY_CONTAINER="platform-gateway"   # container 名称
COMPOSE_FILE="gateway.compose.yml"    # 当前目录下 compose 文件

echo "[host] ==============================="
echo "[host] Starting gateway restart process..."
echo "[host] ==============================="

# ===============================
# 1. 检查旧 container 是否存在
# ===============================
EXISTING_CONTAINER=$(docker ps -a --filter "name=$GATEWAY_CONTAINER" --format "{{.Names}}")

if [ "$EXISTING_CONTAINER" = "$GATEWAY_CONTAINER" ]; then
    echo "[host] Stopping and removing existing container: $GATEWAY_CONTAINER..."
    docker stop "$GATEWAY_CONTAINER"
    docker rm "$GATEWAY_CONTAINER"
else
    echo "[host] No existing container found. Skipping stop/remove."
fi

# ===============================
# 2. 启动新的 container（使用 docker compose）
# ===============================
echo "[host] Starting new container using docker compose..."
docker compose -f "$COMPOSE_FILE" up -d

# ===============================
# 3. 等待 container 启动并检查 nginx 配置
# ===============================
echo "[host] Waiting a few seconds for container to initialize..."
sleep 3

echo "[host] Checking nginx configuration inside the container..."
docker exec "$GATEWAY_CONTAINER" nginx -t

# ===============================
# 4. Reload nginx
# ===============================
echo "[host] Reloading nginx inside the container..."
docker exec "$GATEWAY_CONTAINER" nginx -s reload

echo "[host] ==============================="
echo "[host] Gateway restart completed successfully!"
echo "[host] ==============================="
