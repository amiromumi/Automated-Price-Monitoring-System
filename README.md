# Automated Price Monitoring System

A professional, modular system designed to track asset prices in real-time and deliver automated alerts via Telegram and Desktop notifications. This project demonstrates the integration of system-level automation (Cron), API consumption, and cross-platform notification delivery.

## 🚀 Features
- **Real-time Tracking**: Fetches live data from reliable exchange APIs.
- **Dual-Channel Alerts**: Sends notifications via Telegram Bot API and native Linux desktop alerts (`libnotify`).
- **Autonomous Scheduling**: Fully automated execution using `cron` for zero-maintenance monitoring.
- **Modular Architecture**: Structured to easily support new assets (Gold, BTC, ETH) and different operating systems (Linux, Windows).

## 📂 Project Structure
```
.
├── Linux/               # Linux implementations
│   └── usdt/            # Tether (USDT) monitoring suite
│       ├── tether_price.sh  # General price reporter
│       ├── tether_alert.sh  # Buy-zone threshold monitor
│       └── README.md        # Detailed asset-specific docs
├── Windows/             # Windows implementations (Planned)
├── README.md            # Main documentation
└── README-fa.md         # Main documentation (Persian)
```

## 🛠️ Technology Stack
- **Language**: Bash / Shell Scripting
- **Scheduling**: Cron (Linux)
- **APIs**: REST APIs (JSON)
- **Notifications**: Telegram Bot API, `notify-send` (libnotify)

## ⚡ Quick Start (Linux - USDT)

If you want to get the USDT monitor running quickly:

1. **Clone the repo** and navigate to the USDT folder:
   `cd Linux/usdt`
2. **Set up the scripts**:
   `mkdir -p ~/scripts && cp tether_*.sh ~/scripts/ && chmod +x ~/scripts/tether_*.sh`
3. **Configure**: Edit the scripts to add your `BOT_TOKEN` and `CHAT_ID`.
4. **Schedule**: 
   - For hourly updates: Add `0 * * * * /home/yourusername/scripts/tether_price.sh` to your `crontab -e`.
   - For buy-zone alerts: Add `*/2 * * * * /home/yourusername/scripts/tether_alert.sh` to your `crontab -e`.

For a detailed guide, please refer to `Linux/usdt/README.md`.

## ⚖️ License
MIT License
