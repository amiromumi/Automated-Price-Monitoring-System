#!/bin/bash
# Fix for cron desktop notifications
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus


# --- CONFIGURATION ---
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
PROXY="http://127.0.0.1:10808" # Adjust if needed

# Layered Buy Zones
ZONE_GREEN_MAX=185000   # Aggressive Buy
ZONE_YELLOW_MIN=187500  # Normal Buy
ZONE_YELLOW_MAX=196500  # Normal Buy
ZONE_RED_MIN=200000     # Overpriced / Stop Buy

# Volatility Settings
DROP_THRESHOLD=1.0      # Alert if price drops > 1% in last 10 mins
DB_PATH="/home/amiromumi/Scripts/price_history.db"
STATE_FILE="/home/amiromumi/Scripts/tether_alert.state"

# --- FUNCTIONS ---
send_msg() {
    local msg="$1"
    curl -s -x "$PROXY" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" -d "text=$msg" > /dev/null
}

# Initialize SQLite DB
/usr/bin/sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS history (timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, price REAL);"

# Get Current Price
PRICE_JSON=$(curl -s -x "$PROXY" "https://api.ramzinex.com/api/tether")
PRICE=$(echo "$PRICE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['buy'])")

if [ -z "$PRICE" ]; then
    echo "Error fetching price"
    exit 1
fi

# Save to DB
/usr/bin/sqlite3 "$DB_PATH" "INSERT INTO history (price) VALUES ($PRICE);"

# 1. LAYERED ZONE LOGIC
CURRENT_ZONE="NONE"
if [ "$PRICE" -le "$ZONE_GREEN_MAX" ]; then
    CURRENT_ZONE="GREEN"
    MSG="🟢 فرصت طلایی! قیمت بسیار مناسب است.\n\n💵 قیمت فعلی: $PRICE تومان\n🎯 محدوده: زیر $ZONE_GREEN_MAX"
elif [ "$PRICE" -ge "$ZONE_YELLOW_MIN" ] && [ "$PRICE" -le "$ZONE_YELLOW_MAX" ]; then
    CURRENT_ZONE="YELLOW"
    MSG="🟡 قیمت مناسب است، خرید تدریجی توصیه می‌شود.\n\n💵 قیمت فعلی: $PRICE تومان\n🎯 محدوده: $ZONE_YELLOW_MIN تا $ZONE_YELLOW_MAX"
elif [ "$PRICE" -ge "$ZONE_RED_MIN" ]; then
    CURRENT_ZONE="RED"
    MSG="🔴 قیمت بالا رفته است. توقف خرید پیشنهاد می‌شود.\n\n💵 قیمت فعلی: $PRICE تومان\n🎯 هشدار: بالای $ZONE_RED_MIN"
fi

# State management to avoid spam
LAST_ZONE=$(cat "$STATE_FILE" 2>/dev/null)
if [ "$CURRENT_ZONE" != "NONE" ] && [ "$CURRENT_ZONE" != "$LAST_ZONE" ]; then
    send_msg "🚨 هشدار تغییر محدوده خرید 🚨\n\n$MSG\n\n🕐 $(date '+%H:%M:%S - %d/%m/%Y')"
    echo "$CURRENT_ZONE" > "$STATE_FILE"
fi

# 2. VOLATILITY LOGIC (Drop detection)
# Get price from 10 minutes ago
OLD_PRICE=$(/usr/bin/sqlite3 "$DB_PATH" "SELECT price FROM history WHERE timestamp <= datetime('now', '-10 minutes') ORDER BY timestamp DESC LIMIT 1;")

if [ ! -z "$OLD_PRICE" ]; then
    DIFF=$(python3 -c "print(($OLD_PRICE - $PRICE) / $OLD_PRICE * 100)")
    IS_DROP=$(python3 -c "print(1 if $DIFF > $DROP_THRESHOLD else 0)")
    
    if [ "$IS_DROP" -eq 1 ]; then
        send_msg "⚠️ هشدار ریزش سریع! ⚠️\n\nقیمت در ۱۰ دقیقه اخیر حدود $DIFF% سقوط کرده است.\n\n💵 قیمت فعلی: $PRICE تومان\n📉 قیمت ۱۰ دقیقه پیش: $OLD_PRICE تومان\n\nشاید بهتر باشد برای کف جدید کمی صبر کنید."
    fi
fi
