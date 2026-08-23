# Linux Implementations

This directory contains the operating system-specific implementations for Linux. The focus is on leveraging native Linux tools like `cron` for scheduling and `libnotify` for system-level alerts.

## 📂 Current Assets
Currently, the following assets are implemented for Linux:
- **USDT (Tether)**: Full monitoring suite including hourly reporters and threshold-based alerts. See [`Linux/usdt/README.md`](./usdt/README.md) for details.

## 🛠️ Linux-Specific Approach
For all assets in this directory, we follow a consistent architecture:
1. **Shell Scripting**: Using `.sh` files for maximum compatibility and minimal overhead.
2. **Automation**: Utilizing the system `crontab` to ensure the monitoring runs as a background daemon without requiring a persistent terminal session.
3. **Notification System**:
   - **Remote**: Integration with Telegram Bot API via `curl`.
   - **Local**: Integration with `notify-send` to provide immediate visual feedback on the user's desktop.

## 🚀 Getting Started
To deploy any asset from this directory:
1. Copy the asset's scripts to a stable local directory (e.g., `~/scripts/`).
2. Ensure scripts have executable permissions (`chmod +x`).
3. Configure the API credentials within the scripts.
4. Add the corresponding cron entries to your `crontab`.
