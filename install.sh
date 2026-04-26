#!/bin/bash

# --- Configuration ---
# Change these to match your actual GitHub username and repository name!
GITHUB_USER="putofixe67"
GITHUB_REPO="thinkpad-led-sync"
BRANCH="main"

RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"

echo "=== ThinkPad LED Sync Installer ==="

# 1. Check for brightnessctl
if ! command -v brightnessctl > /dev/null 2>&1; then
    echo "⚠️  'brightnessctl' is not installed."
    echo "Please install it first by running: sudo apt install brightnessctl"
    echo "Then re-run this installer."
    exit 1
fi

# 2. Create the necessary directories
echo "[1/4] Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user

# 3. Download the scripts and service files
echo "[2/4] Downloading files from GitHub..."

# Download Speaker Sync
curl -fsSL "$RAW_URL/mute-led-listener.sh" -o ~/.local/bin/mute-led-listener.sh
curl -fsSL "$RAW_URL/mute-led-listener.service" -o ~/.config/systemd/user/mute-led-listener.service

# Download Mic Sync
curl -fsSL "$RAW_URL/micmute-led-listener.sh" -o ~/.local/bin/micmute-led-listener.sh
curl -fsSL "$RAW_URL/micmute-led-listener.service" -o ~/.config/systemd/user/micmute-led-listener.service

# 4. Apply execute permissions
echo "[3/4] Applying permissions..."
chmod +x ~/.local/bin/mute-led-listener.sh
chmod +x ~/.local/bin/micmute-led-listener.sh

# 5. Enable and start the systemd services
echo "[4/4] Starting background services..."
systemctl --user daemon-reload

systemctl --user enable --now mute-led-listener.service
systemctl --user enable --now micmute-led-listener.service

echo "✅ Installation Complete! Your F1 and F4 LEDs should now sync perfectly."
