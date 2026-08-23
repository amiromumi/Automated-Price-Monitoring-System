# Telegram Bot Setup Guide

This guide walks you through creating a Telegram bot and obtaining your chat ID. All scripts in this project need these two values to send notifications.

[راهنمای فارسی](telegram-bot-setup-fa.md)

## Step 1: Create the Bot

1. Open the Telegram app (mobile or desktop).
2. Search for **@BotFather** — make sure it has the blue verified checkmark.
3. Start a conversation and send `/newbot`.
4. BotFather asks for a **display name** — type anything you like (e.g. `My Price Monitor`).
5. BotFather asks for a **username** — it must end with `bot` (e.g. `my_price_monitor_bot`).
6. BotFather replies with a message containing your **bot token**. It looks like:

   ```
   1234567890:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

7. Copy and save this token securely. This is your `BOT_TOKEN`.

## Step 2: Get Your Chat ID

A bot needs to know which chat to send messages to. Your personal chat ID is a number.

1. In Telegram, search for **@userinfobot** (or **@getmyid_bot** as an alternative).
2. Send it any message (e.g. `hi`).
3. It replies with your account details. The number next to **Id** (or **Your user ID**) is your `CHAT_ID`.

## Step 3: Start Your Bot (Required)

A Telegram bot **cannot** send messages to you until you have initiated the conversation:

1. In Telegram, search for the bot you just created (by its username).
2. Open the chat and press **Start** (or send `/start`).
3. You should see a confirmation from the bot.

If you skip this step, the scripts will report `ok:true` from the API but you will not receive any message in Telegram.

## Step 4: Verify (Optional but Recommended)

Open a terminal and test the bot directly:

```bash
curl -s "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
  -d "chat_id=YOUR_CHAT_ID" \
  --data-urlencode "text=Hello from my monitor!"
```

Replace `YOUR_BOT_TOKEN` and `YOUR_CHAT_ID` with your actual values.

**Expected result:** The terminal prints a JSON response containing `"ok":true` and the test message arrives in your Telegram chat.

### If Telegram is filtered on your network

Add a proxy option to the curl command:

```bash
curl -s --proxy "socks5h://127.0.0.1:10808" \
  "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
  -d "chat_id=YOUR_CHAT_ID" \
  --data-urlencode "text=Hello from my monitor!"
```

Replace `127.0.0.1:10808` with your own proxy address and port.

## Step 5: Put the Values in the Scripts

Open each script you copied to `~/scripts/` and find the configuration section:

```bash
nano ~/scripts/tether_price.sh
nano ~/scripts/tether_alert.sh
```

Replace:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
```

with your real token and chat ID. Save and exit.

## Security Notes

- Never commit your real bot token or chat ID to Git.
- The repository scripts intentionally use placeholder values.
- If your token is ever exposed publicly, revoke it immediately:
  - Open Telegram, find **@BotFather**, send `/revoke` or `/token`, select your bot, and generate a new token. The old token stops working instantly.
- For production deployments, consider storing credentials in a separate file with `chmod 600`.
