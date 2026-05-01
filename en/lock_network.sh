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

if ! command -v dconf &> /dev/null; then
    echo "dconf-cli is not installed. Installing..."
    sudo apt install -y dconf-cli
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
    
    # ✅ 修正: 正しい設定値を含める
    cat | sudo tee "$SETTING_FILE" << 'SETTINGS'
[org/gnome/nm-applet]
disable-wifi-notification=false
suppress-wireless-networks-dialog=true
suppress-wired-networks-dialog=true

[org/gnome/shell]
disable-user-extensions=false
SETTINGS

    # ✅ 修正: ロック対象キー（末尾に / をつけない）
    cat | sudo tee "$LOCK_FILE" << 'LOCKS'
/org/gnome/nm-applet/disable-wifi-notification
/org/gnome/nm-applet/suppress-wireless-networks-dialog
/org/gnome/nm-applet/suppress-wired-networks-dialog
/org/gnome/shell/disable-user-extensions
LOCKS

    sudo dconf update
    zenity --info --text="Network settings locked successfully.\nPlease log out and log back in to apply changes."

elif [ "$ACTION" == "UNLOCK (Restore user access)" ]; then
    sudo rm -f "$SETTING_FILE" "$LOCK_FILE"
    sudo dconf update
    zenity --info --text="Network settings unlocked successfully.\nPlease log out and log back in to apply changes."
else
    echo "Operation cancelled."
    exit 0
fi
