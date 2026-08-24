#!/bin/bash

BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
PROXY="http://127.0.0.1:10808"
DB_PATH="/home/amiromumi/Scripts/price_history.db"

# Get Data from SQLite for the last 24 hours
MIN_PRICE=$(/usr/bin/sqlite3 "$DB_PATH" "SELECT MIN(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
MAX_PRICE=$(/usr/bin/sqlite3 "$DB_PATH" "SELECT MAX(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
AVG_PRICE=$(/usr/bin/sqlite3 "$DB_PATH" "SELECT AVG(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
COUNT=$(/usr/bin/sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM history WHERE timestamp >= datetime('now', '-1 day');")

# Get current price
PRICE_JSON=$(curl -s -x "$PROXY" "https://api.ramzinex.com/api/tether")
CURRENT_PRICE=$(echo "$PRICE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['buy'])")

TREND=$(python3 -c "import sys; try: p=float(sys.argv[1]); a=float(sys.argv[2]); print('صعودی 📈' if p > a else 'نزولی 📉') except: print('نامشخص') " "$CURRENT_PRICE" "$AVG_PRICE")

curl -s -x "$PROXY" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" -d "text=$MSG" > /dev/null
