#!/bin/bash

# Configuration
DB_PATH="/home/amiromumi/Scripts/price_history.db"

echo "Initializing Price Monitoring Database..."

# Create table if not exists
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS history (timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, price REAL);"

if [ $? -eq 0 ]; then
    echo "✅ Database successfully initialized at $DB_PATH"
else
    echo "❌ Error initializing database. Please make sure sqlite3 is installed."
    exit 1
fi
