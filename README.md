🤖 Ubuntu Telegram Server Manager (with Gemini AI)

Tired of SSHing into your server for every little thing?
Now you can just chat with your server on Telegram – like it’s your sysadmin buddy.

Powered by Gemini AI, this bot takes your natural language requests, turns them into Linux commands, runs them safely, and replies with a clean summary.
No more remembering obscure commands – just ask.

✨ What it Can Do

🖥️ Ask about your system
“Hey, what’s the CPU temperature?” → Gets you a friendly answer instead of raw logs

⚙️ Control your server
“Shutdown in 15 minutes” → Schedules it properly

📦 Update packages
“Please update apt” → Runs apt update & upgrade

🌐 Check your network
“What’s the internet speed?” → Uses speedtest-cli if installed

And it does all this by chatting with you in plain English.

🚀 Quick Install

Clone the repo:

```
git clone https://github.com/sev7ne11ven/Ubuntu-Server-Manager-Telegram-Bot.git
cd Ubuntu-Server-Manager-Telegram-Bot
chmod +x setup.sh
sudo ./setup.sh
```

The script will ask you for:

Telegram Bot Token → grab from @BotFather

Gemini API Key → get it at Google AI Studio

Your Telegram User ID → send /start to @userinfobot

That’s it. 🎉 Your bot is now running as a background service and will start automatically on reboot.

🔧 Controlling the Bot

Manage it like any other systemd service:

```
sudo systemctl start telebot_ai
sudo systemctl stop telebot_ai
sudo systemctl restart telebot_ai
```

Peek at the logs if you’re curious:
```
journalctl -u telebot_ai -f
```
🛠️ What Gets Installed

The installer keeps it minimal:

Core stuff: python3, python3-pip, python3-venv, sudo

Python libs: python-telegram-bot, google-generativeai

👉 For some features you’ll need extras:

CPU temp → lm-sensors

Internet speed → speedtest-cli

Network tools → net-tools, iperf3


💡 Example Things You Can Say

“Hey, how much RAM is free?”

“Show me disk usage”

“Reboot the server”

“Update apt”

“Shutdown in 10 minutes”

“What’s my public IP?”

🔒 Security

Only your Telegram ID can control the bot

Everything runs inside a dedicated bot environment

Auto-restarts if it crashes

---

## ❌ Uninstalling

If you want to completely remove the bot:

Run the following inside the cloned repo
```
chmod +x uninstall.sh
sudo ./uninstall.sh
```
This will:

Stop the systemd service

Disable it from autostart

Remove the bot files from /opt/telebot_ai

Clean up the service unit
