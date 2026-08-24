#!/bin/bash

BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
PROXY="http://127.0.0.1:10808"
DB_PATH="/home/amiromumi/Scripts/price_history.db"

# Get Data from SQLite for the last 24 hours
MIN_PRICE=$(sqlite3 "$DB_PATH" "SELECT MIN(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
MAX_PRICE=$(sqlite3 "$DB_PATH" "SELECT MAX(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
AVG_PRICE=$(sqlite3 "$DB_PATH" "SELECT AVG(price) FROM history WHERE timestamp >= datetime('now', '-1 day');")
COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM history WHERE timestamp >= datetime('now', '-1 day');")

# Get current price
PRICE_JSON=$(curl -s -x "$PROXY" "https://api.ramzinex.com/api/tether")
CURRENT_PRICE=$(echo "$PRICE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['buy'])")

MSG="📊 گزارش روزانه مانیتورینگ تتر 📊\n\n📅 بازه زمانی: ۲۴ ساعت گذشته\n\n📉 پایین‌ترین قیمت: $MIN_PRICE\n📈 بالاترین قیمت: $MAX_PRICE\n⚖️ میانگین قیمت: $(printf "%.0f" $AVG_PRICE)\n💵 قیمت فعلی: $CURRENT_PRICE\n\n🔢 تعداد دفعات رصد شده: $COUNT\n\nوضعیت کلی: $(python3 -c "print('صعودی 📈' if $CURRENT_PRICE > $AVG_PRICE else 'نزولی 📉')")"

curl -s -x "$PROXY" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" -d "text=$MSG" > /dev/null
