#!/bin/bash
# Restore Open-WebUI database from backup on deployment

BACKUP_FILE="/var/app/staging/backup/webui.db"
DATA_DIR="/app/backend/data"
DB_FILE="$DATA_DIR/webui.db"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

echo "Checking for backup file at $BACKUP_FILE"

# Restore database if backup exists and is larger than current database
if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE")
    
    if [ -f "$DB_FILE" ]; then
        CURRENT_SIZE=$(stat -c%s "$DB_FILE" 2>/dev/null || stat -f%z "$DB_FILE")
        echo "Current database size: $CURRENT_SIZE bytes"
    else
        CURRENT_SIZE=0
        echo "No existing database found"
    fi
    
    echo "Backup database size: $BACKUP_SIZE bytes"
    
    # Restore if backup is significantly larger (more than 1MB larger)
    if [ $BACKUP_SIZE -gt $((CURRENT_SIZE + 1048576)) ]; then
        echo "Restoring Open-WebUI database from backup..."
        cp "$BACKUP_FILE" "$DB_FILE"
        chmod 644 "$DB_FILE"
        echo "Database restored successfully to $DB_FILE"
    else
        echo "Current database is up to date, skipping restore"
    fi
else
    echo "No backup file found at $BACKUP_FILE"
fi
