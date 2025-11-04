#!/bin/bash

set -e

# Script name
APP_NAME="wordlecow"
APP_URL="https://raw.githubusercontent.com/abhinjata/wordlecow/main/script/wordlecow.sh"

# Check if running in Termux
if [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
    INSTALL_DIR="$PREFIX/bin"
    echo "📱 Detected Termux environment."
    echo "Installing $APP_NAME to $INSTALL_DIR..."
    curl -fsSL "$APP_URL" -o "$INSTALL_DIR/$APP_NAME"
    chmod +x "$INSTALL_DIR/$APP_NAME"
else
    INSTALL_DIR="/usr/local/bin"
    echo "🐧 Detected standard Linux environment."
    echo "Installing $APP_NAME to $INSTALL_DIR (requires sudo)..."
    sudo curl -fsSL "$APP_URL" -o "$INSTALL_DIR/$APP_NAME"
    sudo chmod +x "$INSTALL_DIR/$APP_NAME"
fi

echo "✅ Installed! You can now run '$APP_NAME' from anywhere."
