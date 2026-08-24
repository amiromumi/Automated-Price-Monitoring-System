# Automated Price Monitoring System

A lightweight, modular automation project for monitoring market prices and sending remote Telegram alerts plus local Linux desktop notifications. The current implementation tracks USDT/IRR using the Ramzinex public API and is structured so additional assets and operating systems can be added later.

[راهنمای فارسی](README-fa.md)

## Features

- Live USDT buy/sell prices and 24-hour percentage change
- Scheduled price reports
- Configurable buy-zone monitoring
- Telegram Bot API notifications
- Linux desktop notifications through `notify-send`
- State-based alert suppression to avoid repeated buy-zone messages
- Lightweight Bash and Python implementation with no LLM dependency
- Modular `operating-system/asset` directory layout

## Architecture

```text
Ramzinex REST API
        |
        v
Bash scripts + Python JSON parsing
        |
        +--> Telegram Bot API (remote alert)
        |
        +--> notify-send (local desktop alert)
        |
        +--> local state file (duplicate-alert prevention)
```

## Repository Structure

```text
.
├── docs/
│   ├── telegram-bot-setup.md
│   ├── telegram-bot-setup-fa.md
│   └── LINUX_CRON_SETUP.md       # Comprehensive guide for Linux scheduling
├── Linux/
│   ├── README.md
│   ├── README-fa.md
│   └── usdt/
│       ├── tether_price.sh   # Regular price report
│       ├── tether_alert.sh   # Buy-zone transition monitor
│       ├── README.md
│       └── README-fa.md
├── Windows/
│   └── usdt/
│       ├── tether_price.ps1
│       ├── tether_alert.ps1
│       ├── README.md
│       └── README-fa.md
├── README.md
└── README-fa.md
```

## Technology Stack

- Bash / Shell scripting
- Python 3 for JSON parsing
- `curl` for HTTP requests
- Cron-compatible scheduling
- Telegram Bot API
- `libnotify` / `notify-send`

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System
```

### 2. Set up your Telegram bot
Before using any script, you need a Telegram bot token and your chat ID. Follow the [Telegram Bot Setup Guide](docs/telegram-bot-setup.md).

### 3. Install and configure
```bash
cd Linux/usdt
mkdir -p "$HOME/Scripts"
cp tether_price.sh tether_alert.sh "$HOME/Scripts/"
chmod +x "$HOME/Scripts/tether_price.sh" "$HOME/Scripts/tether_alert.sh"
```
Edit both copied scripts and replace `YOUR_BOT_TOKEN` and `YOUR_CHAT_ID`.

### 4. Test
```bash
bash "$HOME/Scripts/tether_price.sh"
bash "$HOME/Scripts/tether_alert.sh"
```

### 5. Schedule
For detailed step-by-step instructions on setting up the schedule on Linux, please refer to the [Linux Cron Setup Guide](docs/LINUX_CRON_SETUP.md).

## Notification Behavior

- `tether_price.sh` sends a report every time it runs.
- `tether_alert.sh` checks on every scheduled run but sends a buy alert only when the price changes from outside to inside the configured zone. It sends an exit message when the price later leaves that zone.
- Telegram alerts are delivered as long as the machine is powered and has network access.
- Desktop notifications require an active graphical user session.

## Security

- Never commit a real bot token, chat ID, API key, or personal proxy credential.
- Keep repository scripts on placeholder values.
- Revoke and regenerate a Telegram token immediately if it is exposed publicly.
- Restrict local configuration files with `chmod 600` when they contain secrets.

## Troubleshooting

1. Run the script manually and check its exit code.
2. Verify the API and proxy are reachable.
3. Confirm the Telegram bot token and chat ID.
4. Confirm the scheduler service is active.
5. Use absolute paths in scheduled commands.
6. Check that `curl`, `python3`, and `notify-send` are available to the scheduler.

This repository intentionally contains no license section or committed credentials.
