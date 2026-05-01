#!/bin/bash

# Configuration Paths
PROFILE_PATH="/etc/dconf/profile/user"
LOCK_DIR="/etc/dconf/db/local.d/locks"
SETTING_FILE="/etc/dconf/db/local.d/00-network-lock"
LOCK_FILE="$LOCK_DIR/network-lock"

# Check dependencies
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Installing..."
    sudo apt update && sudo apt install -y zenity
fi

# Ensure dconf profile exists
if [ ! -f "$PROFILE_PATH" ]; then
    echo -e "user-db:user\nsystem-db:local" | sudo tee "$PROFILE_PATH"
fi

# GUI Menu
ACTION=$(zenity --list --radiolist --title="Network Lock Manager" \
    --column="Select" --column="Action" \
    TRUE "LOCK (Make settings read-only)" \
    FALSE "UNLOCK (Restore user access)")

if [ "$ACTION" == "LOCK (Make settings read-only)" ]; then
    sudo mkdir -p "$LOCK_DIR"
    echo -e "[org/gnome/desktop/network]\n" | sudo tee "$SETTING_FILE"
    echo -e "/org/gnome/desktop/network/\n/org/gnome/nm-applet/" | sudo tee "$LOCK_FILE"
    
    sudo dconf update
    zenity --info --text="Network settings locked. Please re-login to apply changes."

elif [ "$ACTION" == "UNLOCK (Restore user access)" ]; then
    sudo rm -f "$SETTING_FILE" "$LOCK_FILE"
    sudo dconf update
    zenity --info --text="Network settings unlocked. Please re-login to apply changes."
fi
