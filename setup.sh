#!/usr/bin/env bash
set -euo pipefail

# === Ubuntu Telegram Server Manager with Gemini AI ===
# Installer Script (production-ready)

echo "=============================="
echo "🚀 Ubuntu Telegram AI Server Manager Installer"
echo "=============================="

# --- Check root ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root: sudo ./install_telebot_ai.sh"
  exit 1
fi

# --- Ask user for credentials ---
read -rp "Enter your Telegram Bot Token: " TELEGRAM_TOKEN
read -rp "Enter your Gemini API Key: " GEMINI_API_KEY
read -rp "Enter your Telegram User ID (to authorize admin): " AUTH_USER

# --- System updates & dependencies ---
echo "==> Updating system..."
apt update -y
apt upgrade -y

echo "==> Installing dependencies..."
apt install -y python3 python3-pip python3-venv sudo

# --- Create bot directory ---
BOT_DIR="/opt/telebot_ai"
mkdir -p "$BOT_DIR"
cd "$BOT_DIR"

# --- Setup Python venv ---
echo "==> Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install python-telegram-bot==20.* google-generativeai

# --- Create bot Python file ---
BOT_FILE="$BOT_DIR/bot.py"

cat > "$BOT_FILE" <<EOF
import subprocess
import google.generativeai as genai
from telegram import Update
from telegram.ext import Application, MessageHandler, filters, CallbackContext

# === CONFIG (auto-filled) ===
TELEGRAM_TOKEN = "${TELEGRAM_TOKEN}"
GEMINI_API_KEY = "${GEMINI_API_KEY}"
AUTHORIZED_USER_ID = int("${AUTH_USER}")

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

def ask_gemini(prompt):
    response = model.generate_content(prompt)
    return response.text.strip()

def run_command(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, text=True, timeout=60)
        return output
    except subprocess.CalledProcessError as e:
        return f"Error:\\n{e.output}"
    except subprocess.TimeoutExpired:
        return "Command timed out."

async def handle_message(update: Update, context: CallbackContext):
    if update.message.from_user.id != AUTHORIZED_USER_ID:
        await update.message.reply_text("⛔ Unauthorized user.")
        return

    user_text = update.message.text
    await update.message.reply_text("🤖 Thinking...")

    # Step 1: Ask Gemini to convert natural request → shell command
    gemini_prompt = f"Convert this user request into a Linux shell command. Only output the command. User: '{user_text}'"
    command = ask_gemini(gemini_prompt)

    # Step 2: Run the command
    result = run_command(command)

    # Step 3: Summarize result with Gemini
    summary_prompt = f"User asked: {user_text}\\nCommand run: {command}\\nResult:\\n{result}\\nSummarize result for user."
    summary = ask_gemini(summary_prompt)

    # Step 4: Reply back
    await update.message.reply_text(f"💻 Command: {command}\\n\\n📊 Result:\\n{summary}")

def main():
    app = Application.builder().token(TELEGRAM_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    print("✅ Bot started...")
    app.run_polling()

if __name__ == "__main__":
    main()
EOF

# --- Create systemd service ---
SERVICE_FILE="/etc/systemd/system/telebot_ai.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Telegram AI Server Manager Bot
After=network.target

[Service]
Type=simple
ExecStart=$BOT_DIR/venv/bin/python $BOT_FILE
Restart=on-failure
User=root
WorkingDirectory=$BOT_DIR

[Install]
WantedBy=multi-user.target
EOF

# --- Reload & enable service ---
echo "==> Enabling systemd service..."
systemctl daemon-reload
systemctl enable telebot_ai
systemctl restart telebot_ai

echo "=============================="
echo "✅ Installation complete!"
echo "Your Telegram AI Server Manager bot is running."
echo "It will also auto-start on reboot."
echo "=============================="
