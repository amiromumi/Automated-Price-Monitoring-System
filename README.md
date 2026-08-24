# Automated Price Monitoring System

A professional-grade, modular automation project for monitoring market prices with advanced analysis and remote Telegram alerts.

[راهنمای فارسی](README-fa.md)

## 🌟 Advanced Features

- **Layered Buy Zones:** Multi-tier alerts (Aggressive, Normal, Stop) based on price levels.
- **Volatility Detection:** Rapid drop alerts (e.g., >1% in 10 mins) to prevent FOMO and identify crashes.
- **Daily Intelligence Report:** Automated summary at 17:00 daily including Min/Max/Avg prices and trend analysis.
- **Historical Tracking:** SQLite-powered database for price history and trend calculations.
- **Smart Suppression:** State-based alerts to avoid repeated messages for the same zone.
- **Modular Architecture:** Easy to extend for different assets and OS.

## 🏗️ Architecture

```text
Ramzinex REST API --> Bash/Python Scripts --> SQLite DB (History)
                                       |
                                       +--> Telegram Bot API (Alerts/Reports)
                                       +--> notify-send (Local Alerts)
```

## 📁 Repository Structure

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
│       ├── tether_alert.sh   # Advanced Buy-Zone & Volatility monitor
│       ├── tether_daily_report.sh # Daily intelligence summary
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

## 🛠️ Technology Stack

- **Language:** Bash / Shell scripting
- **Data Processing:** Python 3
- **Database:** SQLite3 (for historical analysis)
- **Networking:** `curl` / HTTP REST
- **Scheduling:** Linux Cron
- **Notifications:** Telegram Bot API / `libnotify`

## 🚀 Quick Start

### 1. Clone & Setup
```bash
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System
cd Linux/usdt
mkdir -p "$HOME/Scripts"
cp *.sh "$HOME/Scripts/"
chmod +x "$HOME/Scripts/"*.sh
```

### 2. Configuration
Edit the scripts in `~/Scripts/` and replace `YOUR_BOT_TOKEN` and `YOUR_CHAT_ID`.

### 3. Scheduling
Refer to the [Linux Cron Setup Guide](docs/LINUX_CRON_SETUP.md) for detailed instructions.

## 📈 Notification Logic

| Level | Condition | Action |
|---|---|---|
| **Green** | < 185,000 | 🟢 Aggressive Buy Alert |
| **Yellow** | 187,500 - 196,500 | 🟡 Normal Buy Alert |
| **Red** | > 200,000 | 🔴 Stop Buy Alert |
| **Crash** | Drop > 1% in 10m | ⚠️ Volatility Warning |
| **Daily** | 17:00 Daily | 📊 Market Summary Report |

This repository intentionally contains no license section or committed credentials.
