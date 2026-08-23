# Linux Implementation

This directory contains the Linux-specific automation layer of the project.

[راهنمای فارسی](README-fa.md)

## Current Module

- [USDT monitor](usdt/README.md): scheduled price reports and state-aware buy-zone alerts.

## Requirements

Debian/Ubuntu example:

```bash
sudo apt update
sudo apt install -y curl python3 libnotify-bin cron
```

Equivalent packages can be installed with your distribution's package manager.

## Recommended File Location

Keep executable copies in a stable user-owned directory:

```bash
mkdir -p "$HOME/scripts"
cp usdt/tether_price.sh usdt/tether_alert.sh "$HOME/scripts/"
chmod +x "$HOME/scripts/tether_price.sh" "$HOME/scripts/tether_alert.sh"
```

Scheduled commands should use absolute paths. Cron may not expand environment variables or use the same `PATH` as an interactive shell.

## Standard Linux Cron

Edit the current user's crontab:

```bash
crontab -e
```

Add:

```cron
0 * * * * /home/yourusername/scripts/tether_price.sh
*/2 * * * * /home/yourusername/scripts/tether_alert.sh
```

Verify:

```bash
crontab -l
systemctl status cron
```

A suspended computer does not execute ordinary scheduled jobs. Depending on the scheduler, missed jobs may run late after resume or may be skipped. Locking the screen is different from suspend: jobs usually continue while the screen is merely locked.

## Desktop Notifications

`notify-send` needs access to the active graphical desktop session. A command can succeed in a terminal yet fail silently from Cron if `DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, or the graphical session is unavailable. Telegram delivery does not depend on the desktop notification channel.

For systems where desktop notifications from Cron are unreliable, consider a user-level `systemd` timer/service tied to the graphical user session. The Telegram notification remains the reliable remote channel.

## Optional Hermes Scheduler

This repository does not require Hermes Agent. If Hermes cron is used instead of system Cron, the Hermes Gateway must stay active:

```bash
hermes gateway install --start-now --start-on-login
hermes gateway status
hermes cron status
```

Use `no_agent` script jobs to avoid LLM calls. When the script itself sends Telegram messages, local scheduler delivery is sufficient; the script is the notification transport.

## Operational Checklist

- Scripts execute manually without errors.
- Real credentials exist only in local copies, never in Git.
- Proxy endpoint is running if configured.
- Scheduler service is active.
- Absolute paths are used.
- The machine is awake at the scheduled time.
- Telegram and desktop channels are tested separately.

See the [USDT guide](usdt/README.md) for configuration, scheduling, testing, and troubleshooting details.
