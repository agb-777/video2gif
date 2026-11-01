#!/usr/bin/env bash

set -e

REPO_URL="https://raw.githubusercontent.com/agb-777/video2gif/refs/heads/main/video2gif"
INSTALL_DIR="/usr/local/bin"
APP_NAME="video2gif"

echo "[*] Updating package lists..."
apt update

echo "[*] Installing dependencies..."
apt install -y ffmpeg gifsicle wget

echo "[*] Downloading ${APP_NAME}..."
wget -O "${APP_NAME}" "$REPO_URL"

echo "[*] Installing ${APP_NAME}..."
chmod +x "${APP_NAME}"
mv "${APP_NAME}" "${INSTALL_DIR}/${APP_NAME}"

echo "[+] Installation completed successfully!"
echo "[+] Run: ${APP_NAME} -h"
