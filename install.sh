#!/bin/bash

set -e

install_docker() {
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

    API_SECRET=$(generate_api_key)

    echo "✅ Saving config to .env"
    echo "API_SECRET=$API_SECRET" > .env
    echo "TARGET_HOST=$TARGET_HOST" >> .env

    echo "🔐 Your API_SECRET: $API_SECRET"
}

install_cli() {
    echo "🚀 Creating CLI command: hawk-proxy"
    sudo tee /usr/local/bin/hawk-proxy > /dev/null <<EOF
#!/bin/bash
cd /opt/hawk-proxy
docker compose "\$@"
EOF
    sudo chmod +x /usr/local/bin/hawk-proxy
}

start_service() {
    echo "🔄 Starting hawk-proxy..."
    docker compose up --build
    echo "✅ hawk-proxy is running. Press Ctrl+C to detach."
}

install_docker
setup_project
configure_env
install_cli
start_service