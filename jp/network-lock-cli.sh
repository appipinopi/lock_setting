#!/bin/bash

# Ubuntu ネットワークロックマネージャー - CLI 版 (日本語)
# 様々な機能を簡単にロック/アンロックできるコマンドラインツール

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # 色なし

# 設定変数
LOCK_STATUS_FILE="/var/lock/network-lock.status"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LOCK_NETWORK_SCRIPT="$SCRIPT_DIR/lock_network.sh"

# 色付きメッセージ出力関数
print_status() {
    echo -e "${BLUE}[情報]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[エラー]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_header() {
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}     Ubuntu ネットワークロックマネージャー - CLI 版${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
}

# root で実行されているか確認
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "このスクリプトは root 権限で実行してください (sudo)"
        exit 1
    fi
}

# ロック状態を確認
check_lock_status() {
    if [ -f "$LOCK_STATUS_FILE" ]; then
        return 0
    else
        return 1
    fi
}

# 個別機能のステータス表示
show_feature_status() {
    echo ""
    print_status "現在のロック状態:"
    echo ""
    
    if check_lock_status; then
        echo -e "  ${GREEN}✓ ネットワークロック: 有効${NC}"
        grep "LOCK_TIME\|LOCKED_BY" "$LOCK_STATUS_FILE" | sed 's/^/    /'
    else
        echo -e "  ${YELLOW}⊘ ネットワークロック: 無効${NC}"
    fi
    
    # 各機能の詳細ステータス
    echo ""
    print_status "機能別ステータス:"
    
    # NetPlan
    if [ -d "/etc/netplan" ]; then
        immutable_count=$(find /etc/netplan -type f \( -name "*.yaml" -o -name "*.yml" \) -exec lsattr {} \; 2>/dev/null | grep -c 'i' || echo "0")
        if [ "$immutable_count" -gt 0 ]; then
            echo -e "  ${GREEN}✓ NetPlan ファイルロック: 有効 ($immutable_count ファイル)${NC}"
        else
            echo -e "  ${YELLOW}⊘ NetPlan ファイルロック: 無効${NC}"
        fi
    fi
    
    # NetworkManager
    if [ -f "/etc/NetworkManager/conf.d/99-lock-settings.conf" ]; then
        echo -e "  ${GREEN}✓ NetworkManager ロック: 有効${NC}"
    else
        echo -e "  ${YELLOW}⊘ NetworkManager ロック: 無効${NC}"
    fi
    
    # Sudoers
    if [ -f "/etc/sudoers.d/network-lock" ]; then
        echo -e "  ${GREEN}✓ コマンド制限: 有効${NC}"
    else
        echo -e "  ${YELLOW}⊘ コマンド制限: 無効${NC}"
    fi
    
    # Interfaces
    if [ -d "/etc/network/interfaces.d" ]; then
        interfaces_immutable=$(find /etc/network/interfaces.d -type f -exec lsattr {} \; 2>/dev/null | grep -c 'i' || echo "0")
        if [ "$interfaces_immutable" -gt 0 ]; then
            echo -e "  ${GREEN}✓ インターフェースロック: 有効 ($interfaces_immutable ファイル)${NC}"
        else
            echo -e "  ${YELLOW}⊘ インターフェースロック: 無効${NC}"
        fi
    fi
    
    echo ""
}

# NetPlan をロック
lock_netplan_only() {
    print_status "NetPlan 設定をロック中..."
    
    if [ -d "/etc/netplan" ]; then
        find "/etc/netplan" -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
            chattr +i "$file"
            print_success "ロック完了: $file"
        done
        chmod 700 "/etc/netplan"
        print_success "NetPlan ディレクトリの権限を制限しました"
    else
        print_warning "NetPlan ディレクトリが見つかりません"
    fi
}

# NetworkManager をロック
lock_networkmanager_only() {
    print_status "NetworkManager 設定をロック中..."
    
    NM_CONFIG="/etc/NetworkManager/NetworkManager.conf"
    NM_CONF_D="/etc/NetworkManager/conf.d"
    
    if [ -f "$NM_CONFIG" ]; then
        if ! grep -q "\\[main\\]" "$NM_CONFIG"; then
            echo "[main]" >> "$NM_CONFIG"
        fi
        
        if ! grep -q "auth-polkit=" "$NM_CONFIG"; then
            echo "auth-polkit=true" >> "$NM_CONFIG"
        fi
    fi
    
    mkdir -p "$NM_CONF_D"
    cat > "$NM_CONF_D/99-lock-settings.conf" << 'EOF'
[main]
# ネットワーク設定をロック
wifi-backend=iwd

[device]
# 管理対象デバイスの変更を防止
managed=true
EOF
    
    chmod 644 "$NM_CONF_D/99-lock-settings.conf"
    print_success "NetworkManager をロックしました"
}

# コマンドを制限
lock_commands_only() {
    print_status "ネットワーク管理コマンドを制限中..."
    
    SUDOERS_D="/etc/sudoers.d"
    
    cat > "$SUDOERS_D/network-lock" << 'EOF'
# ネットワーク設定ロック
# ネットワーク管理コマンドを制限

Cmnd_Alias NETWORK_CMDS = \
    /sbin/ip, \
    /sbin/ifconfig, \
    /usr/bin/nmcli, \
    /usr/sbin/networkctl, \
    /bin/systemctl, \
    /sbin/iptables, \
    /sbin/ip6tables, \
    /usr/sbin/netplan

# root 以外のすべてのユーザーがネットワークコマンドを実行できないようにする
%sudo ALL = (ALL) ALL, !NETWORK_CMDS
EOF
    
    chmod 440 "$SUDOERS_D/network-lock"
    print_success "ネットワークコマンドを制限しました"
}

# インターフェースをロック
lock_interfaces_only() {
    print_status "ネットワークインターフェース設定をロック中..."
    
    if [ -d /etc/network/interfaces.d ]; then
        find /etc/network/interfaces.d -type f | while read -r file; do
            chattr +i "$file"
            print_success "ロック完了: $file"
        done
    fi
}

# USB ポートをロック
lock_usb_ports() {
    print_status "USB ポートをロック中..."
    
    # USB ストレージを無効化
    echo "install usb-storage /bin/true" > /etc/modprobe.d/disable-usb-storage.conf
    print_success "USB ストレージを無効化しました"
    
    # 既存の USB モジュールをアンロード
    modprobe -r usb-storage 2>/dev/null || true
    
    print_success "USB ポートをロックしました"
}

# Bluetooth をロック
lock_bluetooth() {
    print_status "Bluetooth をロック中..."
    
    # Bluetooth サービスを停止
    systemctl stop bluetooth 2>/dev/null || true
    systemctl disable bluetooth 2>/dev/null || true
    
    # Bluetooth モジュールをブラックリスト
    echo "blacklist btusb" > /etc/modprobe.d/disable-bluetooth.conf
    echo "blacklist bluetooth" >> /etc/modprobe.d/disable-bluetooth.conf
    
    print_success "Bluetooth をロックしました"
}

# Wi-Fi をロック
lock_wifi() {
    print_status "Wi-Fi をロック中..."
    
    # RFKill で Wi-Fi をブロック
    rfkill block wifi 2>/dev/null || true
    
    # NetworkManager で Wi-Fi を無効化
    nmcli radio wifi off 2>/dev/null || true
    
    print_success "Wi-Fi をロックしました"
}

# 全てのネットワーク機能をロック
lock_all_features() {
    print_status "=========================================="
    print_status "全てのネットワーク機能をロックします"
    print_status "=========================================="
    
    lock_netplan_only
    lock_networkmanager_only
    lock_interfaces_only
    lock_commands_only
    
    # ステータスファイルを作成
    create_status_file
    
    # サービスを再起動
    print_status "ネットワークサービスを再起動中..."
    systemctl restart networking 2>/dev/null || true
    systemctl restart NetworkManager 2>/dev/null || true
    
    echo ""
    print_success "=========================================="
    print_success "全ての機能がロックされました"
    print_success "=========================================="
}

# ステータスファイルを作成
create_status_file() {
    cat > "$LOCK_STATUS_FILE" << EOF
NETWORK_LOCK_ENABLED=true
LOCK_TIME=$(date '+%Y年%m月%d日 %H:%M:%S')
LOCKED_BY=$(whoami)
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
USB_LOCKED=true
BLUETOOTH_LOCKED=true
WIFI_LOCKED=true
EOF
    
    chmod 600 "$LOCK_STATUS_FILE"
    print_success "ロック状態ファイルを作成しました: $LOCK_STATUS_FILE"
}

# 単一機能のロック解除
unlock_netplan() {
    print_warning "NetPlan のロックを解除中..."
    find "/etc/netplan" -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
        chattr -i "$file"
    done
    print_success "NetPlan のロックを解除しました"
}

unlock_networkmanager() {
    print_warning "NetworkManager のロックを解除中..."
    rm -f /etc/NetworkManager/conf.d/99-lock-settings.conf
    print_success "NetworkManager のロックを解除しました"
}

unlock_commands() {
    print_warning "コマンド制限を解除中..."
    rm -f /etc/sudoers.d/network-lock
    print_success "コマンド制限を解除しました"
}

unlock_interfaces() {
    print_warning "インターフェースのロックを解除中..."
    find /etc/network/interfaces.d -type f 2>/dev/null | while read -r file; do
        chattr -i "$file"
    done
    print_success "インターフェースのロックを解除しました"
}

unlock_usb() {
    print_warning "USB ロックを解除中..."
    rm -f /etc/modprobe.d/disable-usb-storage.conf
    modprobe usb-storage 2>/dev/null || true
    print_success "USB ロックを解除しました"
}

unlock_bluetooth() {
    print_warning "Bluetooth ロックを解除中..."
    rm -f /etc/modprobe.d/disable-bluetooth.conf
    systemctl enable bluetooth 2>/dev/null || true
    systemctl start bluetooth 2>/dev/null || true
    print_success "Bluetooth ロックを解除しました"
}

unlock_wifi() {
    print_warning "Wi-Fi ロックを解除中..."
    rfkill unblock wifi 2>/dev/null || true
    nmcli radio wifi on 2>/dev/null || true
    print_success "Wi-Fi ロックを解除しました"
}

# 全てのロックを解除
unlock_all() {
    print_warning "=========================================="
    print_warning "全てのロックを解除します"
    print_warning "=========================================="
    
    unlock_netplan
    unlock_networkmanager
    unlock_interfaces
    unlock_commands
    unlock_usb
    unlock_bluetooth
    unlock_wifi
    
    rm -f "$LOCK_STATUS_FILE"
    
    echo ""
    print_success "=========================================="
    print_success "全てのロックが解除されました"
    print_success "=========================================="
}

# メニュー表示
show_menu() {
    echo ""
    echo -e "${CYAN}【機能選択メニュー】${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) NetPlan 設定をロック"
    echo -e "  ${GREEN}2${NC}) NetworkManager をロック"
    echo -e "  ${GREEN}3${NC}) ネットワークコマンドを制限"
    echo -e "  ${GREEN}4${NC}) インターフェース設定をロック"
    echo -e "  ${GREEN}5${NC}) USB ポートをロック"
    echo -e "  ${GREEN}6${NC}) Bluetooth をロック"
    echo -e "  ${GREEN}7${NC}) Wi-Fi をロック"
    echo -e "  ${GREEN}8${NC}) ${MAGENTA}全てロック${NC}"
    echo ""
    echo -e "  ${YELLOW}9${NC}) NetPlan ロック解除"
    echo -e "  ${YELLOW}10${NC}) NetworkManager ロック解除"
    echo -e "  ${YELLOW}11${NC}) コマンド制限解除"
    echo -e "  ${YELLOW}12${NC}) インターフェースロック解除"
    echo -e "  ${YELLOW}13${NC}) USB ロック解除"
    echo -e "  ${YELLOW}14${NC}) Bluetooth ロック解除"
    echo -e "  ${YELLOW}15${NC}) Wi-Fi ロック解除"
    echo -e "  ${YELLOW}16${NC}) ${RED}全て解除${NC}"
    echo ""
    echo -e "  ${CYAN}17${NC}) ステータス表示"
    echo -e "  ${CYAN}0${NC}) 終了"
    echo ""
}

# メインループ
main_menu() {
    while true; do
        clear
        print_header
        show_feature_status
        show_menu
        
        read -p "選択してください (0-17): " choice
        
        case $choice in
            1) lock_netplan_only ;;
            2) lock_networkmanager_only ;;
            3) lock_commands_only ;;
            4) lock_interfaces_only ;;
            5) lock_usb_ports ;;
            6) lock_bluetooth ;;
            7) lock_wifi ;;
            8) lock_all_features ;;
            9) unlock_netplan ;;
            10) unlock_networkmanager ;;
            11) unlock_commands ;;
            12) unlock_interfaces ;;
            13) unlock_usb ;;
            14) unlock_bluetooth ;;
            15) unlock_wifi ;;
            16) unlock_all ;;
            17) show_feature_status ;;
            0)
                print_status "終了します。"
                exit 0
                ;;
            *)
                print_error "無効なオプションです"
                ;;
        esac
        
        echo ""
        read -p "Enter キーを押して続行してください..."
    done
}

# コマンドライン引数の処理
case "${1:-}" in
    --status|-s)
        print_header
        show_feature_status
        exit 0
        ;;
    --lock-all|-a)
        check_root
        lock_all_features
        exit 0
        ;;
    --unlock-all|-u)
        check_root
        unlock_all
        exit 0
        ;;
    --lock-netplan)
        check_root
        lock_netplan_only
        exit 0
        ;;
    --lock-nm)
        check_root
        lock_networkmanager_only
        exit 0
        ;;
    --lock-cmd)
        check_root
        lock_commands_only
        exit 0
        ;;
    --lock-usb)
        check_root
        lock_usb_ports
        exit 0
        ;;
    --lock-bt)
        check_root
        lock_bluetooth
        exit 0
        ;;
    --lock-wifi)
        check_root
        lock_wifi
        exit 0
        ;;
    --help|-h)
        print_header
        echo ""
        echo "使用方法:"
        echo "  sudo $0              - インタラクティブモード"
        echo "  sudo $0 --status     - ステータス表示"
        echo "  sudo $0 --lock-all   - 全機能をロック"
        echo "  sudo $0 --unlock-all - 全機能を解除"
        echo ""
        echo "個別ロックオプション:"
        echo "  --lock-netplan  - NetPlan 設定をロック"
        echo "  --lock-nm       - NetworkManager をロック"
        echo "  --lock-cmd      - ネットワークコマンドを制限"
        echo "  --lock-usb      - USB ポートをロック"
        echo "  --lock-bt       - Bluetooth をロック"
        echo "  --lock-wifi     - Wi-Fi をロック"
        echo ""
        exit 0
        ;;
    "")
        check_root
        main_menu
        ;;
    *)
        print_error "不明なオプション: $1"
        echo "ヘルプを表示: sudo $0 --help"
        exit 1
        ;;
esac
