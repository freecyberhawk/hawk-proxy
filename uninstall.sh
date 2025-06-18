#!/bin/bash

set -e

echo "🧹 Uninstalling hawk-proxy..."

# Stop containers
if [ -f /opt/hawk-proxy/docker-compose.yml ]; then
  echo "📦 Stopping docker containers..."
  docker compose -f /opt/hawk-proxy/docker-compose.yml down
fi

# Remove binary
if [ -f /usr/local/bin/hawk-proxy ]; then
  echo "🗑️ Removing CLI from /usr/local/bin..."
  sudo rm -f /usr/local/bin/hawk-proxy
fi

# Remove project directory
if [ -d /opt/hawk-proxy ]; then
  echo "🗑️ Removing /opt/hawk-proxy directory..."
  sudo rm -rf /opt/hawk-proxy
fi

echo "✅ Uninstalled successfully."