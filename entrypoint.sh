#!/bin/sh
set -e

# Generate random UUID if not provided
if [ -z "$UUID" ]; then
  UUID=$(cat /proc/sys/kernel/random/uuid)
  echo "Generated random UUID: $UUID"
fi

# Generate random WebSocket path if not provided
if [ -z "$WS_PATH" ]; then
  WS_PATH="/$(openssl rand -hex 8)"
  echo "Generated random WebSocket path: $WS_PATH"
fi

# Export variables for envsubst
export UUID
export WS_PATH

# Substitute environment variables in the config template
envsubst < /etc/xray/config.template.json > /etc/xray/config.json

echo "Starting Xray with configuration:"
echo "  UUID: $UUID"
echo "  Path: $WS_PATH"
echo "  Port: 8080"

# Execute Xray
exec /usr/bin/xray run -c /etc/xray/config.json
