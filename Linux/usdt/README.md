# USDT Monitoring Scripts (Linux)

This directory contains scripts for monitoring Tether (USDT) prices and sending alerts.

## 1. Installation

To use these scripts on your system:

1. Create a directory for the scripts:
   `mkdir -p ~/scripts`
2. Copy the scripts to that directory:
   `cp tether_price.sh tether_alert.sh ~/scripts/`
3. Make them executable:
   `chmod +x ~/scripts/tether_price.sh ~/scripts/tether_alert.sh`

## 2. Hourly Price Update (tether_price.sh)
This script fetches the current USDT price and sends a summary to Telegram and a desktop notification.

### Customizing the Schedule
The script is designed to be run via `cron`. To schedule it:
1. Run `crontab -e`.
2. Add the following line (replace `yourusername` with your actual Linux username):
   `0 * * * * /home/yourusername/scripts/tether_price.sh`

To change the frequency:
   - `0 * * * *` : Every hour (at minute 0).
   - `*/30 * * * *` : Every 30 minutes.
   - `0 */2 * * *` : Every 2 hours.

## 3. Buy Zone Alert (tether_alert.sh)
This script monitors the price and sends an urgent alert only when the price falls within a specific "Buy Zone".

### Customizing the Buy Zone
Open the script and find the `CONFIGURATION` section:
- `LOWER_BOUND`: The minimum price (in Rials) to trigger the alert.
- `UPPER_BOUND`: The maximum price (in Rials) to trigger the alert.
*Note: 1 Toman = 10 Rials.*

### Customizing the Check Frequency
To schedule the alert check:
1. Run `crontab -e`.
2. Add the following line (replace `yourusername` with your actual Linux username):
   `*/2 * * * * /home/yourusername/scripts/tether_alert.sh`

To change the frequency:
   - `*/2 * * * *` : Every 2 minutes (Default).
   - `*/5 * * * *` : Every 5 minutes.
   - `*/1 * * * *` : Every 1 minute.

## Requirements
- `curl`
- `python3`
- `libnotify` (for `notify-send`)
- A Telegram Bot Token and Chat ID.
