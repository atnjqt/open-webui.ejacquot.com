#!/bin/bash
# .platform/hooks/postdeploy/01_setup_bedrock_gateway.sh
# Sets up bedrock-access-gateway as a systemd service on EC2

set -e

INSTALL_DIR="/opt/bedrock-access-gateway"
REPO_URL="https://github.com/aws-samples/bedrock-access-gateway.git"
API_KEY="bedrock-access-key"  # Match the key in environment.config

echo "Setting up Bedrock Access Gateway..."

# Install Python 3.11
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11..."
    sudo yum install -y python3.11 python3.11-pip
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo yum install -y git
fi

# Clone repository if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Cloning bedrock-access-gateway repository..."
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
else
    echo "Repository already exists, pulling latest changes..."
    cd "$INSTALL_DIR"
    sudo git pull || echo "Git pull failed, continuing..."
fi

# Create virtual environment with Python 3.11
echo "Creating virtual environment with Python 3.11..."
if [ -d "$INSTALL_DIR/venv" ]; then
    sudo rm -rf "$INSTALL_DIR/venv"
fi
sudo python3.11 -m venv "$INSTALL_DIR/venv"

# Install Python dependencies in virtual environment
echo "Installing Python dependencies..."
cd "$INSTALL_DIR/src"
sudo "$INSTALL_DIR/venv/bin/pip" install --upgrade pip 2>&1 || echo "Pip upgrade skipped"
sudo "$INSTALL_DIR/venv/bin/pip" install fastapi==0.116.1 pydantic==2.11.4 uvicorn==0.29.0 mangum==0.17.0 tiktoken==0.9.0 requests==2.32.4 numpy boto3 botocore

# Create environment file
echo "Creating environment file..."
sudo tee "$INSTALL_DIR/.env" > /dev/null <<EOF
API_KEY=$API_KEY
ENABLE_PROMPT_CACHING=true
EOF

# Create systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/bedrock-gateway.service > /dev/null <<EOF
[Unit]
Description=Bedrock Access Gateway - OpenAI-compatible API for Amazon Bedrock
After=network.target

[Service]
Type=simple
WorkingDirectory=$INSTALL_DIR/src
EnvironmentFile=$INSTALL_DIR/.env
ExecStart=$INSTALL_DIR/venv/bin/uvicorn api.app:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable service to start on boot
echo "Enabling bedrock-gateway service..."
sudo systemctl enable bedrock-gateway

# Restart service to apply changes
echo "Starting bedrock-gateway service..."
sudo systemctl restart bedrock-gateway

# Wait a moment for service to start
sleep 2

# Check service status
if sudo systemctl is-active --quiet bedrock-gateway; then
    echo "✓ Bedrock Gateway service is running"
    curl -s http://localhost:8000/health || echo "Health check endpoint not responding yet"
    echo "Bedrock Access Gateway setup complete!"
    exit 0
else
    echo "✗ Failed to start bedrock-gateway service"
    sudo journalctl -u bedrock-gateway -n 50 --no-pager || true
    echo "Service may still be starting up, but continuing deployment..."
    exit 0
fi
