#!/bin/bash

echo -e "\033[1;36m"
cat << "EOF"
  _  _             _     ___
 | || |__ ___ __ _| |__ | _ \_ _ _____ ___  _
 | __ / _` \ V  V / / / |  _/ '_/ _ \ \ / || |
 |_||_\__,_|\_/\_/|_\_\ |_| |_| \___/_\_\\_, |
                                         |__/
EOF
echo -e "          github.com/\033[4mfreecyberhawk\033[0m"
echo -e "\033[0m"
# --- End: Hawk Proxy Banner ---
set -e

install_docker() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "✅ Docker and Docker Compose already installed. Skipping installation."
        return
    fi

    echo "Installing Docker (if needed)..."
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
    echo "✅ Installing Docker (if needed)..."
}

generate_api_key() {
    openssl rand -hex 16
}

setup_project() {
    echo "Setting up hawk-proxy"
    sudo rm -rf /opt/hawk-proxy
    sudo mkdir -p /opt/hawk-proxy
    sudo git clone https://github.com/freecyberhawk/hawk-proxy.git /opt/hawk-proxy
    cd /opt/hawk-proxy
    echo "✅ Hawk-proxy successfully set up at /opt/hawk-proxy"
}

configure_env() {
    echo -n "Enter target domain (e.g. panelDomain.com): "
    read TARGET_HOST

    echo -n "Enter tunnel port (e.g. 8080): "
    read TUNNEL_PORT

    if [ -z "$TUNNEL_PORT" ]; then
        TUNNEL_PORT=8080
        echo -e "TUNNEL_PORT was not provided. Set to default: \033[0;31m8080\033[0m"
    fi

    echo -n "Enter your API_SECRET (leave empty to auto-generate): "
    read API_SECRET

    if [ -z "$API_SECRET" ]; then
        API_SECRET=$(generate_api_key)
        echo "No API_SECRET provided. Generated one automatically."
    fi

    echo "Saving config to .env"
    echo "API_SECRET=$API_SECRET" > .env
    echo "TARGET_HOST=$TARGET_HOST" >> .env
    echo "TUNNEL_PORT=$TUNNEL_PORT" >> .env

    echo -e "🔐 Your API_SECRET: \033[0;31m$API_SECRET\033[0m"

    echo "✅ Config saved to .env"

}

install_cli() {
    echo "Creating CLI command: hawk-proxy"
    sudo tee /usr/local/bin/hawk-proxy > /dev/null <<'EOF'
#!/bin/bash
cd /opt/hawk-proxy

case "$1" in
  up)
    docker compose up --build -d
    ;;
  down)
    docker compose down
    ;;
  logs)
    docker compose logs -f
    ;;
  *)
    echo "Usage: hawk-proxy {up | down | logs}"
    ;;
esac
EOF

    sudo chmod +x /usr/local/bin/hawk-proxy
    echo "✅ CLI commands created"
}


start_service() {
    docker compose up --build -d
    echo "✅ Hawk Proxy is running in background."
}

install_docker
setup_project
configure_env
install_cli
start_service