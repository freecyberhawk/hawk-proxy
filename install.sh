#!/bin/bash

set -e

APP_NAME="hawk-proxy"
INSTALL_DIR="/opt/$APP_NAME"
BIN_PATH="/usr/local/bin/$APP_NAME"
REPO_URL="https://github.com/freecyberhawk/hawk-proxy.git"

echo "🔍 Checking for Docker..."

if ! command -v docker &> /dev/null; then
  echo "🐳 Docker not found. Installing Docker..."

  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update

  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "✅ Docker installed."
else
  echo "✅ Docker already installed."
fi

echo "📦 Installing $APP_NAME..."

if [ ! -d "$INSTALL_DIR" ]; then
  sudo git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo "🔁 Updating existing installation..."
  cd "$INSTALL_DIR"
  sudo git pull
fi

cat <<EOF | sudo tee "$BIN_PATH" > /dev/null
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

sudo chmod +x "$BIN_PATH"
echo "✅ Installed CLI as '$APP_NAME' in /usr/local/bin"

echo ""
echo "🚀 Starting $APP_NAME..."
docker compose -f "$INSTALL_DIR/docker-compose.yml" up -d

echo ""
echo "📺 Showing logs now. Press Ctrl+C to exit."
echo "👉 From now on, use '$APP_NAME up|down|status|logs' to control the proxy."

sleep 1
docker compose -f "$INSTALL_DIR/docker-compose.yml" logs -f