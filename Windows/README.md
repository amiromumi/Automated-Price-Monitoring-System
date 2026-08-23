# Tether Price Report (Windows PowerShell)

This script fetches the current USDT/IRR price from the Ramzinex API and sends a report via Telegram and a local Windows notification.

## Configuration
Edit the variables at the top of the script:
- BOT_TOKEN: Your Telegram Bot token.
- CHAT_ID: Your personal Telegram Chat ID.
- PROXY: Your SOCKS5 proxy (e.g., 'socks5://127.0.0.1:10808'). Leave empty if not needed.

## How it works
1. Fetches JSON data from Ramzinex API.
2. Parses the current buy/sell prices and 24h change.
3. Sends the formatted report to Telegram.
4. Displays a Windows Toast notification.

## Scheduling
Use Windows Task Scheduler to run this script every hour.
Example: Create a task that runs `powershell.exe -ExecutionPolicy Bypass -File C:\scripts\tether_price.ps1`.
