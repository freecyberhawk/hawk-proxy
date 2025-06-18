#!/bin/bash

set -e

install_docker() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "✅ Docker and Docker Compose already installed. Skipping installation."
        return
    fi

    echo "🔧 Installing Docker (if needed)..."
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

generate_api_key() {
    openssl rand -hex 16
}

setup_project() {
    echo "📁 Setting up hawk-proxy in /opt/hawk-proxy ..."
    sudo rm -rf /opt/hawk-proxy
    sudo mkdir -p /opt/hawk-proxy
    sudo git clone https://github.com/freecyberhawk/hawk-proxy.git /opt/hawk-proxy
    cd /opt/hawk-proxy
}

configure_env() {
    echo -n "🌐 Enter target domain (e.g. subscription-domain.com): "
    read TARGET_HOST

    echo -n "🔑 Enter your API_SECRET (leave empty to auto-generate): "
    read API_SECRET

    if [ -z "$API_SECRET" ]; then
        API_SECRET=$(generate_api_key)
        echo "⚙️  No API_SECRET provided. Generated one automatically."
    fi

    echo "✅ Saving config to .env"
    echo "API_SECRET=$API_SECRET" > .env
    echo "TARGET_HOST=$TARGET_HOST" >> .env

    echo -e "🔐 Your API_SECRET: \033[0;31m$API_SECRET\033[0m"
}

install_cli() {
    echo "🚀 Creating CLI command: hawk-proxy"
    sudo tee /usr/local/bin/hawk-proxy > /dev/null <<EOF
cd /opt/hawk-proxy

case "$1" in
    up)
      docker compose up --build -d
    ;;
  down)
    docker compose down
    ;;
  status)
    if docker compose ps | grep -q "Up"; then
      echo "running"
    else
      echo "stopped"
    fi
    ;;
  *)
    echo "Usage: hawk-proxy {up|down|status}"
    ;;
esac
EOF
    sudo chmod +x /usr/local/bin/hawk-proxy
}

start_service() {
    echo "🔄 Starting hawk-proxy in background (detached)..."
    docker compose up --build -d
    echo "✅ hawk-proxy is running in background."
}

install_docker
setup_project
configure_env
install_cli
start_service