#!/usr/bin/env bash
set -euo pipefail

# === Ubuntu Telegram Server Manager Uninstaller ===

echo "=============================="
echo "🗑️  Uninstalling Ubuntu Telegram AI Server Manager"
echo "=============================="

# --- Check root ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root: sudo ./uninstall_telebot_ai.sh"
  exit 1
fi

SERVICE_NAME="telebot_ai"
BOT_DIR="/opt/telebot_ai"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# --- Stop and disable systemd service ---
if systemctl list-units --full -all | grep -q "$SERVICE_NAME.service"; then
  echo "==> Stopping and disabling service..."
  systemctl stop "$SERVICE_NAME" || true
  systemctl disable "$SERVICE_NAME" || true
fi

# --- Remove service file ---
if [[ -f "$SERVICE_FILE" ]]; then
  echo "==> Removing service file..."
  rm -f "$SERVICE_FILE"
  systemctl daemon-reload
fi

# --- Remove bot directory ---
if [[ -d "$BOT_DIR" ]]; then
  echo "==> Removing bot files..."
  rm -rf "$BOT_DIR"
fi

echo "✅ Uninstall complete. The bot and all its files have been removed."
