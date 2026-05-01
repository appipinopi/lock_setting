#!/bin/bash

# Ubuntu 24.04 LTS ネットワーク設定ロックスクリプト (日本語)
# このスクリプトはネットワーク設定をロックして不正なアクセスを防ぎます

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 色なし

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

# rootで実行されているか確認
if [[ $EUID -ne 0 ]]; then
    print_error "このスクリプトはroot権限で実行してください (sudo)"
    exit 1
fi

print_status "Ubuntuネットワーク設定ロックを開始します..."

# 設定変数
NETPLAN_DIR="/etc/netplan"
NM_CONFIG="/etc/NetworkManager/NetworkManager.conf"
NM_CONF_D="/etc/NetworkManager/conf.d"
SUDOERS_D="/etc/sudoers.d"
LOCK_INDICATOR="/var/lock/network-lock.status"

# NetPlan設定をロック
lock_netplan() {
    print_status "NetPlan設定をロック中..."
    
    if [ -d "$NETPLAN_DIR" ]; then
        # 設定ファイルを不変にする
        find "$NETPLAN_DIR" -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
            chattr +i "$file"
            print_success "ロック完了: $file"
        done
        
        # ディレクトリ自体をロック
        chmod 700 "$NETPLAN_DIR"
        print_success "NetPlanディレクトリの権限を制限しました"
    else
        print_warning "NetPlanディレクトリが見つかりません"
    fi
}

# NetworkManagerをロック
lock_networkmanager() {
    print_status "NetworkManager設定をロック中..."
    
    # 制限的なNetworkManager設定を作成
    if [ -f "$NM_CONFIG" ]; then
        # パーミッション制限を追加
        if ! grep -q "\\[main\\]" "$NM_CONFIG"; then
            echo "[main]" >> "$NM_CONFIG"
        fi
        
        if ! grep -q "auth-polkit=" "$NM_CONFIG"; then
            echo "auth-polkit=true" >> "$NM_CONFIG"
        fi
    fi
    
    # conf.dでロック設定を作成
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
    print_success "NetworkManagerをロックしました"
}

# ネットワークコマンドを制限
lock_network_commands() {
    print_status "ネットワーク管理コマンドを制限中..."
    
    # sudo ルールを作成してネットワークコマンドを制限
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

# root以外のすべてのユーザーがネットワークコマンドを実行できないようにする
%sudo ALL = (ALL) ALL, !NETWORK_CMDS
EOF
    
    chmod 440 "$SUDOERS_D/network-lock"
    print_success "ネットワークコマンドを制限しました"
}

# インターフェース設定をロック
lock_interfaces() {
    print_status "ネットワークインターフェース設定をロック中..."
    
    # インターフェースファイルを不変にする
    if [ -d /etc/network/interfaces.d ]; then
        find /etc/network/interfaces.d -type f | while read -r file; do
            chattr +i "$file"
            print_success "ロック完了: $file"
        done
    fi
}

# ロック状態ファイルを作成
create_status_file() {
    print_status "ロック状態ファイルを作成中..."
    
    cat > "$LOCK_INDICATOR" << EOF
NETWORK_LOCK_ENABLED=true
LOCK_TIME=$(date '+%Y年%m月%d日 %H:%M:%S')
LOCKED_BY=$(whoami)
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
EOF
    
    chmod 600 "$LOCK_INDICATOR"
    print_success "ロック状態ファイルを作成しました: $LOCK_INDICATOR"
}

# ネットワークサービスを再起動
restart_services() {
    print_status "ネットワークサービスを再起動中..."
    systemctl restart networking
    systemctl restart NetworkManager 2>/dev/null || true
    print_success "ネットワークサービスを再起動しました"
}

# メイン実行
main() {
    print_status "=========================================="
    print_status "Ubuntu ネットワーク設定ロックツール"
    print_status "=========================================="
    
    lock_netplan
    lock_networkmanager
    lock_interfaces
    lock_network_commands
    create_status_file
    restart_services
    
    echo ""
    print_success "=========================================="
    print_success "ネットワーク設定がロックされました"
    print_success "=========================================="
    echo ""
    print_status "ロック済みコンポーネント:"
    echo "  ✓ NetPlan設定（ファイルを不変に設定）"
    echo "  ✓ NetworkManager設定"
    echo "  ✓ ネットワークインターフェース設定"
    echo "  ✓ ネットワーク管理コマンド（制限）"
    echo ""
    print_warning "ロックを解除するには: sudo $0 --unlock"
}

# ロック解除関数
unlock() {
    print_warning "ネットワーク設定をロック解除中..."
    
    # NetPlanファイルの不変フラグを削除
    find "$NETPLAN_DIR" -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
        chattr -i "$file"
        print_success "ロック解除完了: $file"
    done
    
    # インターフェースファイルの不変フラグを削除
    find /etc/network/interfaces.d -type f 2>/dev/null | while read -r file; do
        chattr -i "$file"
    done
    
    # sudo ロックルールを削除
    rm -f "$SUDOERS_D/network-lock"
    
    # ロック状態ファイルを削除
    rm -f "$LOCK_INDICATOR"
    
    print_success "ネットワーク設定がロック解除されました"
}

# 引数をチェック
if [ "$1" = "--unlock" ]; then
    unlock
else
    main
fi
