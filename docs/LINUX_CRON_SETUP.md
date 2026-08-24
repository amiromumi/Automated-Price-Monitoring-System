# Linux Cron Setup Guide

This guide provides detailed instructions on how to schedule the price monitoring scripts using the system's native cron daemon.

## 1. What is Cron?
Cron is a time-based job scheduler in Unix-like operating systems. It allows you to run scripts automatically at specific intervals.

## 2. Accessing the Crontab
To edit your user's scheduled tasks, run the following command in your terminal:
```bash
crontab -e
```
*If prompted to choose an editor, `nano` is recommended for beginners.*

## 3. Scheduling the Scripts
Add the following lines to the bottom of your crontab file. **Replace `yourusername` with your actual Linux username (e.g., `amiromumi`).**

### Hourly Price Report
Sends a general price update every hour.
```cron
0 * * * * /home/yourusername/Scripts/tether_price.sh >> /home/yourusername/Scripts/price_log.log 2>&1
```

### 2-Minute Buy-Zone Monitor
Checks the price every 2 minutes and alerts only if a buy-zone transition occurs.
```cron
*/2 * * * * /home/yourusername/Scripts/tether_alert.sh >> /home/yourusername/Scripts/alert_log.log 2>&1
```

## 4. Understanding the Cron Syntax
A cron entry consists of five time fields followed by the command:
`* * * * * command`
- **Minute (0-59):** `*/2` means every 2nd minute.
- **Hour (0-23):** `0` means exactly at the start of the hour.
- **Day of Month (1-31):** `*` means every day.
- **Month (1-12):** `*` means every month.
- **Day of Week (0-6):** `*` means every day of the week.

## 5. Logging and Debugging
The `>> /path/to/log 2>&1` part is critical. It ensures that both standard output and error messages are saved to a file.

To check if your scripts are running correctly, you can tail the logs in real-time:
```bash
tail -f ~/Scripts/price_log.log
```

## 6. Important Tips
- **Absolute Paths:** Always use absolute paths (e.g., `/home/user/script.sh` instead of `~/script.sh`) because cron runs in a limited environment.
- **Permissions:** Ensure your scripts are executable:
  ```bash
  chmod +x ~/Scripts/*.sh
  ```
- **Persistence:** Cron jobs persist after reboot. However, if your system hibernates, jobs scheduled during sleep may be missed.
