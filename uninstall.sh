#!/bin/bash

echo "⚠️  Are you sure you want to uninstall hawk-proxy? (yes/no)"
read confirm
if [[ "$confirm" != "yes" ]]; then
    echo "❌ Uninstallation aborted."
    exit 1
fi

echo "🛑 Stopping Docker containers..."
cd /opt/hawk-proxy 2>/dev/null && docker compose down || true

echo "🧹 Removing project files..."
sudo rm -rf /opt/hawk-proxy

echo "🧼 Removing CLI command..."
sudo rm -f /usr/local/bin/hawk-proxy

echo "🗑️  Removing environment file..."
sudo rm -f /opt/hawk-proxy/.env

echo "✅ hawk-proxy has been uninstalled completely."