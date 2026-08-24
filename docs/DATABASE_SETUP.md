# Database Setup Guide

This project uses **SQLite3**, a lightweight, file-based database, to track price history and perform trend analysis.

## 🛠️ Architecture
The database is stored as a single file: `price_history.db`. It doesn't require a server and is managed directly by the Bash scripts.

## 📊 Schema
The database contains a table named `history` with the following structure:

| Column | Type | Description |
|---|---|---|
| `timestamp` | DATETIME | The exact date and time the price was recorded (Default: CURRENT_TIMESTAMP) |
| `price` | REAL | The USDT/IRR buy price |

## 🚀 How it Works
1. **Data Collection:** Every time `tether_alert.sh` runs, it inserts the current price into the `history` table.
2. **Analysis:** The `tether_daily_report.sh` and volatility logic use SQL queries to calculate `MIN()`, `MAX()`, and `AVG()` prices over specific time windows (e.g., last 24 hours or last 10 minutes).

## 💻 Useful SQL Queries
If you want to explore the data manually, you can use the `sqlite3` CLI:

**View last 10 records:**
```bash
sqlite3 /home/yourusername/Scripts/price_history.db "SELECT * FROM history ORDER BY timestamp DESC LIMIT 10;"
```

**Calculate average price for today:**
```bash
sqlite3 /home/yourusername/Scripts/price_history.db "SELECT AVG(price) FROM history WHERE timestamp >= date('now');"
```

## ⚙️ Setup
The database is automatically created the first time you run the scripts. However, you can also use the provided `init_db.sh` script to initialize it manually.
