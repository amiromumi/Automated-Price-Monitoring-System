# USDT Monitoring on Linux

Two lightweight scripts monitor USDT/IRR using the Ramzinex public API.

[راهنمای فارسی](README-fa.md)

## Scripts

| Script | Purpose | Recommended schedule |
|---|---|---|
| `tether_price.sh` | Sends the current buy/sell price and 24-hour change every time it runs | Hourly |
| `tether_alert.sh` | Checks the configured buy zone and sends messages only on state transitions | Every 2–5 minutes |

## Requirements

- Linux
- Bash
- `curl`
- Python 3
- `notify-send` from `libnotify` for desktop notifications
- Telegram bot token and target chat ID
- Optional SOCKS5 proxy

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y curl python3 libnotify-bin cron
```

## Telegram Bot Setup

Before using these scripts, you need a Telegram bot token and your chat ID. See the [Telegram Bot Setup Guide](../../docs/telegram-bot-setup.md) for a step-by-step walkthrough.

## Installation

Install the required tools, clone the repository, and copy the scripts:

```bash
# 1. Install dependencies (Debian/Ubuntu; use your distro's package manager otherwise)
sudo apt update
sudo apt install -y curl python3 libnotify-bin cron git

# 2. Clone the repository
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System/Linux/usdt

# 3. Copy the scripts to a stable location
mkdir -p "$HOME/scripts"
cp tether_price.sh tether_alert.sh "$HOME/scripts/"

# 4. Make them executable
chmod +x "$HOME/scripts/tether_price.sh" "$HOME/scripts/tether_alert.sh"
```

Do not edit and schedule files directly inside a temporary clone if the repository may later be moved or deleted. Use a stable path such as `$HOME/scripts`.


## Configuration

Edit both local copies:

```bash
nano "$HOME/scripts/tether_price.sh"
nano "$HOME/scripts/tether_alert.sh"
```

Replace:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
```

Proxy configuration defaults to:

```bash
PROXY="socks5h://127.0.0.1:10808"
```

If no proxy is required, remove `--proxy "$PROXY"` from Telegram `curl` calls or adapt the script for an empty proxy setting. Never commit real credentials.

### Buy-zone units

`tether_alert.sh` stores bounds in Iranian rials:

```bash
LOWER_BOUND=1800000
UPPER_BOUND=2000000
```

Because `1 toman = 10 rials`, these example values represent 180,000 to 200,000 tomans.

## Test Manually

```bash
bash "$HOME/scripts/tether_price.sh"
printf 'price exit code: %s\n' "$?"

bash "$HOME/scripts/tether_alert.sh"
printf 'alert exit code: %s\n' "$?"
```

`tether_alert.sh` may produce no message even when successful. This is expected when the price remains in the same state. It uses `/tmp/.tether_alert_state` to prevent duplicate messages:

- `OUT -> IN_ZONE`: send buy alert
- `IN_ZONE -> IN_ZONE`: remain silent
- `IN_ZONE -> OUT`: send exit alert
- `OUT -> OUT`: remain silent

For a clean transition test, remove the state file only when you intentionally want to reset that history:

```bash
rm -f /tmp/.tether_alert_state
```

## Schedule with Standard Cron

Open the current user's crontab:

```bash
crontab -e
```

Add these lines, replacing `yourusername`:

```cron
0 * * * * /home/yourusername/scripts/tether_price.sh >> /home/yourusername/tether_price.log 2>&1
*/2 * * * * /home/yourusername/scripts/tether_alert.sh >> /home/yourusername/tether_alert.log 2>&1
```

Check the configuration and service:

```bash
crontab -l
systemctl status cron
```

Cron examples:

- `0 * * * *`: every hour at minute zero
- `*/30 * * * *`: every 30 minutes
- `*/2 * * * *`: every 2 minutes
- `*/5 * * * *`: every 5 minutes

## Optional Hermes Scheduling

Hermes Agent is not required by this repository. If you choose Hermes cron, copy the scripts into its script directory and keep the Gateway running:

```bash
cp "$HOME/scripts/tether_price.sh" "$HOME/.hermes/scripts/"
cp "$HOME/scripts/tether_alert.sh" "$HOME/.hermes/scripts/"
hermes gateway install --start-now --start-on-login
hermes gateway status
hermes cron status
```

Use no-agent script jobs. The scripts already send their own Telegram and desktop notifications, so scheduler delivery should be local to avoid duplicate or unresolved gateway delivery.

## Sleep, Lock Screen, and Desktop Alerts

- Screen locked, machine awake: scheduled jobs normally continue.
- System suspended/sleeping: scripts do not run until the system wakes; a missed schedule may be skipped or delayed.
- Telegram: works without a graphical desktop if the machine, scheduler, proxy, and network are active.
- Desktop notification: requires access to an active graphical session and D-Bus. It may be absent when the machine is suspended or when launched from a scheduler without desktop-session variables.

## Troubleshooting

### Telegram does not arrive

1. Run the exact script manually.
2. Verify the bot token and chat ID.
3. Test the configured proxy.
4. Temporarily inspect the Telegram API response instead of redirecting it to `/dev/null`.
5. Ensure the bot is not blocked and the target conversation exists.

### Desktop notification does not arrive

```bash
notify-send "USDT monitor test" "Desktop notifications are available"
```

If manual notification works but scheduled notification does not, investigate the graphical session, `DISPLAY`, and `DBUS_SESSION_BUS_ADDRESS`, or use a user-level systemd timer.

### Scheduled job never runs

- Confirm the scheduler service is active.
- Use absolute paths.
- Confirm execute permission with `ls -l "$HOME/scripts"`.
- Check log files from the cron examples.
- Confirm the computer was awake at the scheduled time.
- For Hermes cron specifically, run `hermes gateway status` and `hermes cron status`.

## Security

- Repository scripts intentionally use placeholders.
- Never commit Telegram tokens, chat IDs, private proxy credentials, or personal paths containing secrets.
- If a token is exposed, revoke it through BotFather and generate a new token.
- Consider storing local secrets in a separate file with mode `600` for production deployments.

This project intentionally has no license section.
