#!/bin/bash
# Monitor USDT/IRR price and alert when in buy zone
# Runs every 2 minutes via cron job

# --- CONFIGURATION ---
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
PROXY="socks5h://127.0.0.1:10808" # Change or remove if not using proxy

# Set your buy zone in Rials (Toman * 10)
LOWER_BOUND=1800000   # Example: 180,000 Toman
UPPER_BOUND=2000000   # Example: 200,000 Toman
# ---------------------

STATE_FILE="/tmp/.tether_alert_state"

RESPONSE=$(curl -s --max-time 15 "https://publicapi.ramzinex.com/exchange/api/v1.0/exchange/pairs" 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    exit 1
fi

PRICE_RIAL=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('data', []):
    if item.get('base_currency_symbol', {}).get('en') == 'usdt':
        print(item.get('sell', 0))
        break
" 2>/dev/null)

if [ -z "$PRICE_RIAL" ] || [ "$PRICE_RIAL" = "0" ]; then
    exit 1
fi

PRICE_TOMAN=$((PRICE_RIAL / 10))
PRICE_FMT=$(printf "%'d" "$PRICE_TOMAN")

if [ "$PRICE_RIAL" -ge "$LOWER_BOUND" ] && [ "$PRICE_RIAL" -le "$UPPER_BOUND" ]; then
    if [ -f "$STATE_FILE" ]; then
        LAST_STATE=$(cat "$STATE_FILE")
        if [ "$LAST_STATE" = "IN_ZONE" ]; then
            exit 0
        fi
    fi

    NOW=$(TZ='Asia/Tehran' date '+%H:%M:%S - %d/%m/%Y')
    MSG=$(printf "🚨 هشدار خرید تتر 🚨\n\n✅ قیمت تتر وارد محدوده خرید شد!\n\n💵 قیمت فعلی: %s تومان\n🎯 محدوده خرید: %s تا %s تومان\n\n🕐 %s" "$PRICE_FMT" "$((LOWER_BOUND/10))" "$((UPPER_BOUND/10))" "$NOW")

    curl -s --max-time 15 --proxy "$PROXY" \
        "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${MSG}" \
        > /dev/null 2>&1

    notify-send -u critical "🚨 هشدار خرید تتر!" "قیمت: $PRICE_FMT تومان - در محدوده خرید" 2>/dev/null
    echo "IN_ZONE" > "$STATE_FILE"
else
    if [ -f "$STATE_FILE" ]; then
        LAST_STATE=$(cat "$STATE_FILE")
        if [ "$LAST_STATE" = "IN_ZONE" ]; then
            NOW=$(TZ='Asia/Tehran' date '+%H:%M:%S - %d/%m/%Y')
            MSG=$(printf "ℹ️ قیمت تتر از محدوده خرید خارج شد\n\n💵 قیمت فعلی: %s تومان\n\n🕐 %s" "$PRICE_FMT" "$NOW")
            curl -s --max-time 15 --proxy "$PROXY" \
                "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                --data-urlencode "text=${MSG}" \
                > /dev/null 2>&1
            notify-send "ℹ️ تتر خارج از محدوده خرید" "قیمت: $PRICE_FMT تومان" 2>/dev/null
        fi
    fi
    echo "OUT" > "$STATE_FILE"
fi
