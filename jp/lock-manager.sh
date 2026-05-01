#!/bin/bash

# Ubuntu ネットワークロックマネージャー - クイックコントロール (日本語)
# ネットワークロック状態を簡単に管理するインターフェース

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOCK_STATUS_FILE="/var/lock/network-lock.status"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MAIN_SCRIPT="$SCRIPT_DIR/network-lock.sh"

print_header() {
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Ubuntu ネットワークロックマネージャー${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
}

check_status() {
    if [ -f "$LOCK_STATUS_FILE" ]; then
        echo -e "${GREEN}✓ ネットワークロックは有効です${NC}"
        echo ""
        echo "ロック情報:"
        grep "LOCK_TIME\|LOCKED_BY\|NETPLAN_LOCKED\|NETWORKMANAGER_LOCKED\|COMMANDS_RESTRICTED" "$LOCK_STATUS_FILE" | sed 's/^/  /'
        return 0
    else
        echo -e "${YELLOW}⊘ ネットワークロックは無効です${NC}"
        return 1
    fi
}

show_menu() {
    echo ""
    echo "選択肢:"
    echo -e "  ${CYAN}1${NC}) ネットワークロックを有効化"
    echo -e "  ${CYAN}2${NC}) ネットワークロックを無効化"
    echo -e "  ${CYAN}3${NC}) ステータスを確認"
    echo -e "  ${CYAN}4${NC}) 終了"
    echo ""
}

enable_lock() {
    echo -e "${YELLOW}ネットワークロックを有効化中...${NC}"
    if [ -f "$MAIN_SCRIPT" ]; then
        sudo bash "$MAIN_SCRIPT"
    else
        echo -e "${RED}エラー: $MAIN_SCRIPT が見つかりません${NC}"
        return 1
    fi
}

disable_lock() {
    echo -e "${YELLOW}ネットワークロックを無効化してもよろしいですか? (yes/no)${NC}"
    read -r confirm
    if [ "$confirm" = "yes" ]; then
        if [ -f "$MAIN_SCRIPT" ]; then
            sudo bash "$MAIN_SCRIPT" --unlock
        else
            echo -e "${RED}エラー: network-lock.sh が見つかりません${NC}"
            return 1
        fi
    else
        echo "キャンセルしました。"
    fi
}

main_menu() {
    while true; do
        clear
        print_header
        echo ""
        check_status
        show_menu
        read -p "選択してください (1-4): " choice
        
        case $choice in
            1)
                enable_lock
                read -p "Enterキーを押して続行してください..."
                ;;
            2)
                disable_lock
                read -p "Enterキーを押して続行してください..."
                ;;
            3)
                check_status
                read -p "Enterキーを押して続行してください..."
                ;;
            4)
                echo -e "${CYAN}ご利用ありがとうございました!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}無効なオプションです${NC}"
                read -p "Enterキーを押して続行してください..."
                ;;
        esac
    done
}

# ステータス表示モード
if [ "$1" = "--status" ]; then
    print_header
    check_status
    exit 0
fi

# インタラクティブメニューモード
main_menu
