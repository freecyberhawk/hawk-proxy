#!/bin/bash

set -e

APP_NAME="hawk-proxy"
INSTALL_DIR="/opt/$APP_NAME"
BIN_PATH="/usr/local/bin/$APP_NAME"
REPO_URL="https://github.com/freecyberhawk/hawk-proxy.git"

echo "📦 Installing $APP_NAME..."

if [ ! -d "$INSTALL_DIR" ]; then
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo "🔁 Updating existing installation..."
  cd "$INSTALL_DIR"
  git pull
fi

cat <<EOF > "$BIN_PATH"
#!/bin/bash
cd $INSTALL_DIR

case "\$1" in
  up)
    docker compose up -d
    ;;
  down)
    docker compose down
    ;;
  status)
    docker compose ps
    ;;
  logs)
    docker compose logs -f
    ;;
  *)
    echo "Usage: $APP_NAME {up|down|status|logs}"
    exit 1
    ;;
esac
EOF

chmod +x "$BIN_PATH"
echo "✅ Installed CLI as '$APP_NAME' in /usr/local/bin"

echo ""
echo "🚀 Starting $APP_NAME..."
docker compose -f "$INSTALL_DIR/docker-compose.yml" up -d

echo ""
echo "📺 Showing logs now. Press Ctrl+C to exit."
echo "👉 From now on, use '$APP_NAME up|down|status|logs' to control the proxy."

sleep 1
docker compose -f "$INSTALL_DIR/docker-compose.yml" logs -f