LOCK_PATH="/etc/dconf/db/local.d/locks"
SETTING_FILE="/etc/dconf/db/local.d/00-network-lock"
LOCK_FILE="$LOCK_PATH/network-lock"

ACTION=$(zenity --list --radiolist --title="ネットワーク設定ロック" \
    --column="選択" --column="アクション" \
    TRUE "LOCK (設定を固定する)" \
    FALSE "UNLOCK (ロックを解除する)")

if [ "$ACTION" == "LOCK (設定を固定する)" ]; then
    sudo mkdir -p "$LOCK_PATH"

    echo -e "[org/gnome/desktop/network]\n" | sudo tee "$SETTING_FILE"

    echo -e "/org/gnome/desktop/network/\n/org/gnome/nm-applet/" | sudo tee "$LOCK_FILE"

    sudo dconf update
    zenity --info --text="有線設定をロックしました。再ログイン後に反映されます。"

elif [ "$ACTION" == "UNLOCK (ロックを解除する)" ]; then
    sudo rm -f "$SETTING_FILE" "$LOCK_FILE"

    sudo dconf update
    zenity --info --text="ロックを解除しました。再ログイン後に反映されます。"
fi
