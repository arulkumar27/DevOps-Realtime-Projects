#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${1:?Usage: blue-green-deploy.sh IMAGE}"
APP_NAME="product-service"
STATE_DIR="/opt/${APP_NAME}"
NGINX_CONFIG="/etc/nginx/sites-available/${APP_NAME}"

mkdir -p "$STATE_DIR"
CURRENT_COLOR="$(cat "$STATE_DIR/current-color" 2>/dev/null || echo green)"

if [[ "$CURRENT_COLOR" == "blue" ]]; then
  NEW_COLOR="green"
  NEW_PORT="8082"
  OLD_COLOR="blue"
else
  NEW_COLOR="blue"
  NEW_PORT="8081"
  OLD_COLOR="green"
fi

echo "Deploying ${IMAGE} as ${NEW_COLOR} on port ${NEW_PORT}"
docker rm -f "${APP_NAME}-${NEW_COLOR}" 2>/dev/null || true
docker run -d \
  --name "${APP_NAME}-${NEW_COLOR}" \
  --restart unless-stopped \
  -p "127.0.0.1:${NEW_PORT}:8080" \
  -e "APP_VERSION=${BUILD_NUMBER:-manual}" \
  --memory=512m \
  --cpus=1.0 \
  "$IMAGE"

healthy=false
for attempt in {1..20}; do
  if curl --fail --silent "http://127.0.0.1:${NEW_PORT}/actuator/health" | grep -q '"status":"UP"'; then
    healthy=true
    break
  fi
  echo "Health check ${attempt}/20..."
  sleep 3
done

if [[ "$healthy" != "true" ]]; then
  echo "New container is unhealthy. Removing it; old version remains live."
  docker logs "${APP_NAME}-${NEW_COLOR}" || true
  docker rm -f "${APP_NAME}-${NEW_COLOR}" || true
  exit 1
fi

sudo sed -i -E "s/server 127\.0\.0\.1:[0-9]+;/server 127.0.0.1:${NEW_PORT};/" "$NGINX_CONFIG"
sudo nginx -t
sudo systemctl reload nginx

if ! curl --fail --silent http://127.0.0.1/api/info >/dev/null; then
  echo "Public endpoint failed. Rolling Nginx back."
  OLD_PORT=$([[ "$OLD_COLOR" == "blue" ]] && echo 8081 || echo 8082)
  sudo sed -i -E "s/server 127\.0\.0\.1:[0-9]+;/server 127.0.0.1:${OLD_PORT};/" "$NGINX_CONFIG"
  sudo systemctl reload nginx
  docker rm -f "${APP_NAME}-${NEW_COLOR}" || true
  exit 1
fi

echo "$NEW_COLOR" > "$STATE_DIR/current-color"
docker rm -f "${APP_NAME}-${OLD_COLOR}" 2>/dev/null || true
docker image prune -f
echo "Deployment successful: ${NEW_COLOR} is live."
