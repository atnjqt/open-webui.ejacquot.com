#!/bin/bash
# .platform/hooks/postdeploy/02_setup_apache_tika.sh
# Runs apache/tika:latest-full as a systemd-managed Docker container on port 9998
# Open WebUI can reach it at http://host.docker.internal:9998

set -e

TIKA_IMAGE="apache/tika:latest-full"
CONTAINER_NAME="tika"
TIKA_PORT="9998"

echo "Setting up Apache Tika..."

# Ensure Docker is available
if ! command -v docker &> /dev/null; then
    echo "✗ Docker not found — cannot continue"
    exit 1
fi

# Pull the latest image
echo "Pulling $TIKA_IMAGE..."
docker pull "$TIKA_IMAGE"

# Create systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/apache-tika.service > /dev/null <<EOF
[Unit]
Description=Apache Tika Server
After=docker.service network.target
Requires=docker.service

[Service]
Type=simple
Restart=always
RestartSec=10
# Remove any leftover container before starting
ExecStartPre=-/usr/bin/docker stop $CONTAINER_NAME
ExecStartPre=-/usr/bin/docker rm $CONTAINER_NAME
ExecStart=/usr/bin/docker run --name $CONTAINER_NAME \
    -p ${TIKA_PORT}:${TIKA_PORT} \
    --rm \
    $TIKA_IMAGE
ExecStop=/usr/bin/docker stop $CONTAINER_NAME
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling apache-tika service..."
sudo systemctl enable apache-tika

echo "Starting apache-tika service..."
sudo systemctl restart apache-tika

# Give Tika a few seconds to initialise (it's a JVM app)
sleep 5

if sudo systemctl is-active --quiet apache-tika; then
    echo "✓ Apache Tika service is running on port $TIKA_PORT"
    echo ""
    echo "Configure Open WebUI:"
    echo "  Admin Panel → Settings → Documents"
    echo "  Content Extraction Engine : Tika"
    echo "  Tika URL                  : http://host.docker.internal:${TIKA_PORT}"
    exit 0
else
    echo "✗ Apache Tika service failed to start"
    sudo journalctl -u apache-tika -n 50 --no-pager || true
    echo "Continuing deployment — service may still be starting up"
    exit 0
fi
