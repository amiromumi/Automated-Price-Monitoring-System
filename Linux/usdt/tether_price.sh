#!/bin/bash
# Fetch USDT/IRR price from Ramzinex and send to Telegram bot
# Runs hourly via cron job

# --- CONFIGURATION ---
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
PROXY="socks5h://127.0.0.1:10808" # Change or remove if not using proxy
# ---------------------

# Fetch price from Ramzinex API
RESPONSE=$(curl -s --max-time 15 "https://publicapi.ramzinex.com/exchange/api/v1.0/exchange/pairs" 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    exit 1
fi

# Extract USDT prices
BUY_RIAL=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('data', []):
    if item.get('base_currency_symbol', {}).get('en') == 'usdt':
        print(item.get('buy', 0))
        break
" 2>/dev/null)

SELL_RIAL=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('data', []):
    if item.get('base_currency_symbol', {}).get('en') == 'usdt':
        print(item.get('sell', 0))
        break
" 2>/dev/null)

CHANGE_PCT=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('data', []):
    if item.get('base_currency_symbol', {}).get('en') == 'usdt':
        print(item.get('financial', {}).get('last24h', {}).get('change_percent', 0))
        break
" 2>/dev/null)

if [ -z "$BUY_RIAL" ] || [ "$BUY_RIAL" = "0" ]; then
    exit 1
fi

BUY_TOMAN=$((BUY_RIAL / 10))
SELL_TOMAN=$((SELL_RIAL / 10))
BUY_FMT=$(printf "%'d" "$BUY_TOMAN")
SELL_FMT=$(printf "%'d" "$SELL_TOMAN")
NOW=$(TZ='Asia/Tehran' date '+%H:%M - %d/%m/%Y')

MSG=$(printf "💵 قیمت تتر (تومان)\n\n🟢 خرید: %s\n🔴 فروش: %s\n📈 تغییر ۲۴ ساعت: %s%%\n\n🕐 %s" "$BUY_FMT" "$SELL_FMT" "$CHANGE_PCT" "$NOW")

# Send to Telegram
curl -s --max-time 15 --proxy "$PROXY" \
    "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    --data-urlencode "text=${MSG}" \
    > /dev/null 2>&1

# Desktop notification
SHORT_MSG=$(printf "خرید: %s تومان | فروش: %s تومان" "$BUY_FMT" "$SELL_FMT")
notify-send "💵 قیمت تتر" "$SHORT_MSG" 2>/dev/null

echo "$MSG"
