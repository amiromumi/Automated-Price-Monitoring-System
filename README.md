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
├── Linux/
│   ├── README.md
│   ├── README-fa.md
│   └── usdt/
│       ├── tether_price.sh   # Regular price report
│       ├── tether_alert.sh   # Buy-zone transition monitor
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

```bash
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System/Linux/usdt
mkdir -p "$HOME/scripts"
cp tether_price.sh tether_alert.sh "$HOME/scripts/"
chmod +x "$HOME/scripts/tether_price.sh" "$HOME/scripts/tether_alert.sh"
```

Edit both copied scripts and replace `YOUR_BOT_TOKEN` and `YOUR_CHAT_ID`. If no SOCKS proxy is required, remove the `--proxy "$PROXY"` option or adapt the proxy configuration.

Test before scheduling:

```bash
bash "$HOME/scripts/tether_price.sh"
bash "$HOME/scripts/tether_alert.sh"
```

Then use your preferred scheduler. Standard Linux cron examples:

```cron
0 * * * * /home/yourusername/scripts/tether_price.sh
*/2 * * * * /home/yourusername/scripts/tether_alert.sh
```

See [Linux documentation](Linux/README.md) and the detailed [USDT setup guide](Linux/usdt/README.md).

## Notification Behavior

- `tether_price.sh` sends a report every time it runs.
- `tether_alert.sh` checks on every scheduled run but sends a buy alert only when the price changes from outside to inside the configured zone. It sends an exit message when the price later leaves that zone.
- Telegram alerts can arrive while the computer display is locked or asleep only if the machine and scheduler are still running and network access remains available.
- Desktop notifications require an active graphical user session. They may not appear while the computer is suspended, while the display session is unavailable, or when the scheduler lacks access to the desktop D-Bus session.

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
7. Treat Telegram delivery and desktop notification delivery as separate channels: one can work while the other does not.

This repository intentionally contains no license section or committed credentials.
