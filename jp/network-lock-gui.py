#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Ubuntu ネットワークロックマネージャー - GUI 版 (日本語)
様々な機能を簡単にロック/アンロックできるグラフィカルインターフェース
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os
import sys
from datetime import datetime

# 設定変数
LOCK_STATUS_FILE = "/var/lock/network-lock.status"

class NetworkLockGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Ubuntu ネットワークロックマネージャー - GUI 版")
        self.root.geometry("900x700")
        self.root.minsize(800, 600)
        
        # スタイル設定
        self.setup_styles()
        
        # メインフレーム
        self.main_frame = ttk.Frame(root, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # 列と行の設定
        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        self.main_frame.columnconfigure(0, weight=1)
        
        # UI 構築
        self.create_header()
        self.create_status_frame()
        self.create_lock_controls()
        self.create_output_area()
        self.create_button_frame()
        
        # 初期ステータス表示
        self.update_status_display()
    
    def setup_styles(self):
        """スタイルを設定"""
        style = ttk.Style()
        
        # カラースキーム
        colors = {
            'header.bg': '#2c3e50',
            'header.fg': '#ecf0f1',
            'success': '#27ae60',
            'warning': '#f39c12',
            'danger': '#e74c3c',
            'info': '#3498db',
        }
        
        # ヘッダースタイル
        style.configure('Header.TLabel', 
                       background=colors['header.bg'],
                       foreground=colors['header.fg'],
                       font=('Helvetica', 16, 'bold'),
                       padding=10)
        
        # セクションスタイル
        style.configure('Section.TLabelframe', 
                       font=('Helvetica', 12, 'bold'))
        style.configure('Section.TLabelframe.Label',
                       font=('Helvetica', 12, 'bold'))
        
        # ボタンスタイル
        style.configure('Lock.TButton',
                       font=('Helvetica', 10, 'bold'),
                       padding=5)
        style.configure('Unlock.TButton',
                       font=('Helvetica', 10),
                       padding=5)
        style.configure('Action.TButton',
                       font=('Helvetica', 11, 'bold'),
                       padding=10)
    
    def create_header(self):
        """ヘッダーを作成"""
        header_frame = ttk.Frame(self.main_frame)
        header_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        header_frame.columnconfigure(0, weight=1)
        
        title_label = ttk.Label(header_frame, 
                               text="🔐 Ubuntu ネットワークロックマネージャー",
                               style='Header.TLabel')
        title_label.grid(row=0, column=0, sticky=(tk.W, tk.E))
        
        subtitle_label = ttk.Label(header_frame,
                                  text="システムセキュリティ保護ツール",
                                  style='Header.TLabel')
        subtitle_label.grid(row=1, column=0, sticky=(tk.W, tk.E))
    
    def create_status_frame(self):
        """ステータス表示フレームを作成"""
        status_frame = ttk.LabelFrame(self.main_frame, 
                                     text="📊 現在のロック状態",
                                     style='Section.TLabelframe',
                                     padding=10)
        status_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        status_frame.columnconfigure(1, weight=1)
        
        # ステータスラベル
        self.status_labels = {}
        status_items = [
            ('network_lock', 'ネットワークロック全体'),
            ('netplan', 'NetPlan ファイル'),
            ('networkmanager', 'NetworkManager'),
            ('commands', 'コマンド制限'),
            ('interfaces', 'インターフェース'),
            ('usb', 'USB ポート'),
            ('bluetooth', 'Bluetooth'),
            ('wifi', 'Wi-Fi'),
        ]
        
        for i, (key, label_text) in enumerate(status_items):
            row = i // 2
            col = (i % 2) * 2
            
            lbl = ttk.Label(status_frame, text=f"{label_text}:")
            lbl.grid(row=row, column=col, sticky=tk.W, padx=5, pady=2)
            
            status_lbl = ttk.Label(status_frame, text="確認中...", width=15)
            status_lbl.grid(row=row, column=col+1, sticky=tk.W, padx=5, pady=2)
            self.status_labels[key] = status_lbl
    
    def create_lock_controls(self):
        """ロックコントロールフレームを作成"""
        control_frame = ttk.LabelFrame(self.main_frame,
                                      text="🔒 ロック機能の選択",
                                      style='Section.TLabelframe',
                                      padding=10)
        control_frame.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        control_frame.columnconfigure(0, weight=1)
        
        # グリッドレイアウト
        buttons_frame = ttk.Frame(control_frame)
        buttons_frame.grid(row=0, column=0, sticky=(tk.W, tk.E))
        
        # ボタン設定
        button_configs = [
            ("NetPlan ロック", "lock_netplan", 0, 0),
            ("NetworkManager ロック", "lock_nm", 0, 1),
            ("コマンド制限", "lock_cmd", 0, 2),
            ("インターフェース", "lock_ifaces", 0, 3),
            ("USB ロック", "lock_usb", 1, 0),
            ("Bluetooth ロック", "lock_bt", 1, 1),
            ("Wi-Fi ロック", "lock_wifi", 1, 2),
            ("全てロック", "lock_all", 1, 3),
        ]
        
        self.lock_buttons = {}
        for text, cmd, row, col in button_configs:
            btn = ttk.Button(buttons_frame, 
                           text=text,
                           command=lambda c=cmd: self.execute_lock(c),
                           style='Lock.TButton')
            btn.grid(row=row, column=col, padx=5, pady=5, sticky=(tk.W, tk.E))
            self.lock_buttons[cmd] = btn
        
        # 均等な幅に設定
        for i in range(4):
            buttons_frame.columnconfigure(i, weight=1)
    
    def create_unlock_controls(self, parent, row):
        """アンロックコントロールを作成"""
        unlock_frame = ttk.Frame(parent)
        unlock_frame.grid(row=row, column=0, sticky=(tk.W, tk.E), pady=(5, 0))
        unlock_frame.columnconfigure(0, weight=1)
        
        buttons_frame = ttk.Frame(unlock_frame)
        buttons_frame.grid(row=0, column=0)
        
        button_configs = [
            ("NetPlan 解除", "unlock_netplan"),
            ("NM 解除", "unlock_nm"),
            ("コマンド解除", "unlock_cmd"),
            ("IF 解除", "unlock_ifaces"),
            ("USB 解除", "unlock_usb"),
            ("BT 解除", "unlock_bt"),
            ("WiFi 解除", "unlock_wifi"),
            ("全て解除", "unlock_all"),
        ]
        
        for text, cmd in button_configs:
            btn = ttk.Button(buttons_frame,
                           text=text,
                           command=lambda c=cmd: self.execute_unlock(c),
                           style='Unlock.TButton')
            btn.pack(side=tk.LEFT, padx=3, pady=2)
    
    def create_output_area(self):
        """出力エリアを作成"""
        output_frame = ttk.LabelFrame(self.main_frame,
                                     text="📝 実行ログ",
                                     style='Section.TLabelframe',
                                     padding=10)
        output_frame.grid(row=3, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        output_frame.columnconfigure(0, weight=1)
        output_frame.rowconfigure(0, weight=1)
        
        self.output_text = scrolledtext.ScrolledText(output_frame,
                                                    height=10,
                                                    wrap=tk.WORD,
                                                    font=('Consolas', 9))
        self.output_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # タグで色を設定
        self.output_text.tag_configure('info', foreground='#3498db')
        self.output_text.tag_configure('success', foreground='#27ae60')
        self.output_text.tag_configure('warning', foreground='#f39c12')
        self.output_text.tag_configure('error', foreground='#e74c3c')
    
    def create_button_frame(self):
        """ボタンフレームを作成"""
        button_frame = ttk.Frame(self.main_frame)
        button_frame.grid(row=4, column=0, sticky=(tk.W, tk.E))
        button_frame.columnconfigure(0, weight=1)
        button_frame.columnconfigure(1, weight=1)
        button_frame.columnconfigure(2, weight=1)
        
        # リフレッシュボタン
        refresh_btn = ttk.Button(button_frame,
                                text="🔄 ステータス更新",
                                command=self.update_status_display,
                                style='Action.TButton')
        refresh_btn.grid(row=0, column=0, padx=5, pady=5)
        
        # ヘルプボタン
        help_btn = ttk.Button(button_frame,
                             text="❓ ヘルプ",
                             command=self.show_help,
                             style='Action.TButton')
        help_btn.grid(row=0, column=1, padx=5, pady=5)
        
        # 終了ボタン
        exit_btn = ttk.Button(button_frame,
                             text="🚪 終了",
                             command=self.root.quit,
                             style='Action.TButton')
        exit_btn.grid(row=0, column=2, padx=5, pady=5)
    
    def log_message(self, message, level='info'):
        """ログメッセージを出力"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.output_text.insert(tk.END, f"[{timestamp}] {message}\n", level)
        self.output_text.see(tk.END)
    
    def check_root(self):
        """root 権限を確認"""
        if os.geteuid() != 0:
            messagebox.showerror("エラー", 
                               "このアプリケーションは root 権限が必要です。\n"
                               "sudo で実行してください:\n"
                               "sudo python3 network-lock-gui.py")
            return False
        return True
    
    def run_command(self, command, description=""):
        """コマンドを実行"""
        try:
            if description:
                self.log_message(f"実行中：{description}", 'info')
            
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                if result.stdout:
                    self.log_message(result.stdout.strip(), 'success')
                return True
            else:
                if result.stderr:
                    self.log_message(result.stderr.strip(), 'error')
                return False
                
        except subprocess.TimeoutExpired:
            self.log_message("コマンドがタイムアウトしました", 'error')
            return False
        except Exception as e:
            self.log_message(f"エラー：{str(e)}", 'error')
            return False
    
    def execute_lock(self, action):
        """ロックアクションを実行"""
        if not self.check_root():
            return
        
        commands = {
            'lock_netplan': ('find /etc/netplan -type f \\( -name "*.yaml" -o -name "*.yml" \\) -exec chattr +i {} \\;', 'NetPlan ロック'),
            'lock_nm': ('mkdir -p /etc/NetworkManager/conf.d && echo -e "[main]\\nwifi-backend=iwd\\n\\n[device]\\nmanaged=true" > /etc/NetworkManager/conf.d/99-lock-settings.conf', 'NetworkManager ロック'),
            'lock_cmd': ('echo -e "# ネットワーク設定ロック\\nCmnd_Alias NETWORK_CMDS = /sbin/ip, /sbin/ifconfig, /usr/bin/nmcli, /usr/sbin/networkctl, /bin/systemctl, /sbin/iptables, /sbin/ip6tables, /usr/sbin/netplan\\n%sudo ALL = (ALL) ALL, !NETWORK_CMDS" > /etc/sudoers.d/network-lock && chmod 440 /etc/sudoers.d/network-lock', 'コマンド制限'),
            'lock_ifaces': ('find /etc/network/interfaces.d -type f -exec chattr +i {} \\; 2>/dev/null || true', 'インターフェースロック'),
            'lock_usb': ('echo "install usb-storage /bin/true" > /etc/modprobe.d/disable-usb-storage.conf && modprobe -r usb-storage 2>/dev/null || true', 'USB ロック'),
            'lock_bt': ('systemctl stop bluetooth 2>/dev/null; systemctl disable bluetooth 2>/dev/null; echo -e "blacklist btusb\\nblacklist bluetooth" > /etc/modprobe.d/disable-bluetooth.conf', 'Bluetooth ロック'),
            'lock_wifi': ('rfkill block wifi 2>/dev/null || true; nmcli radio wifi off 2>/dev/null || true', 'Wi-Fi ロック'),
            'lock_all': (None, '全てロック'),
        }
        
        if action == 'lock_all':
            self.lock_all_features()
            return
        
        if action in commands:
            cmd, desc = commands[action]
            self.run_command(cmd, desc)
            self.update_status_display()
    
    def execute_unlock(self, action):
        """アンロックアクションを実行"""
        if not self.check_root():
            return
        
        commands = {
            'unlock_netplan': ('find /etc/netplan -type f \\( -name "*.yaml" -o -name "*.yml" \\) -exec chattr -i {} \\;', 'NetPlan 解除'),
            'unlock_nm': ('rm -f /etc/NetworkManager/conf.d/99-lock-settings.conf', 'NetworkManager 解除'),
            'unlock_cmd': ('rm -f /etc/sudoers.d/network-lock', 'コマンド制限解除'),
            'unlock_ifaces': ('find /etc/network/interfaces.d -type f -exec chattr -i {} \\; 2>/dev/null || true', 'インターフェース解除'),
            'unlock_usb': ('rm -f /etc/modprobe.d/disable-usb-storage.conf && modprobe usb-storage 2>/dev/null || true', 'USB 解除'),
            'unlock_bt': ('rm -f /etc/modprobe.d/disable-bluetooth.conf && systemctl enable bluetooth 2>/dev/null; systemctl start bluetooth 2>/dev/null', 'Bluetooth 解除'),
            'unlock_wifi': ('rfkill unblock wifi 2>/dev/null || true; nmcli radio wifi on 2>/dev/null || true', 'Wi-Fi 解除'),
            'unlock_all': (None, '全て解除'),
        }
        
        if action == 'unlock_all':
            if messagebox.askyesno("確認", "全てのロックを解除しますか？"):
                self.unlock_all_features()
            return
        
        if action in commands:
            cmd, desc = commands[action]
            self.run_command(cmd, desc)
            self.update_status_display()
    
    def lock_all_features(self):
        """全ての機能をロック"""
        self.log_message("========================================", 'info')
        self.log_message("全ての機能をロックします", 'info')
        self.log_message("========================================", 'info')
        
        actions = ['lock_netplan', 'lock_nm', 'lock_ifaces', 'lock_cmd', 'lock_usb', 'lock_bt', 'lock_wifi']
        for action in actions:
            self.execute_lock(action)
        
        # ステータスファイル作成
        self.create_status_file()
        self.log_message("全ての機能がロックされました", 'success')
    
    def unlock_all_features(self):
        """全ての機能を解除"""
        self.log_message("========================================", 'warning')
        self.log_message("全ての機能を解除します", 'warning')
        self.log_message("========================================", 'warning')
        
        actions = ['unlock_netplan', 'unlock_nm', 'unlock_ifaces', 'unlock_cmd', 'unlock_usb', 'unlock_bt', 'unlock_wifi']
        for action in actions:
            self.execute_unlock(action)
        
        # ステータスファイル削除
        try:
            if os.path.exists(LOCK_STATUS_FILE):
                os.remove(LOCK_STATUS_FILE)
                self.log_message("ステータスファイルを削除しました", 'success')
        except Exception as e:
            self.log_message(f"ステータスファイル削除エラー：{e}", 'error')
        
        self.log_message("全ての機能が解除されました", 'success')
    
    def create_status_file(self):
        """ステータスファイルを作成"""
        try:
            with open(LOCK_STATUS_FILE, 'w') as f:
                f.write(f"NETWORK_LOCK_ENABLED=true\n")
                f.write(f"LOCK_TIME={datetime.now().strftime('%Y年%m月%d日 %H:%M:%S')}\n")
                f.write(f"LOCKED_BY=root\n")
                f.write(f"NETPLAN_LOCKED=true\n")
                f.write(f"NETWORKMANAGER_LOCKED=true\n")
                f.write(f"COMMANDS_RESTRICTED=true\n")
                f.write(f"INTERFACES_LOCKED=true\n")
                f.write(f"USB_LOCKED=true\n")
                f.write(f"BLUETOOTH_LOCKED=true\n")
                f.write(f"WIFI_LOCKED=true\n")
            self.log_message("ステータスファイルを作成しました", 'success')
        except Exception as e:
            self.log_message(f"ステータスファイル作成エラー：{e}", 'error')
    
    def update_status_display(self):
        """ステータス表示を更新"""
        self.log_message("ステータスを確認中...", 'info')
        
        # ネットワークロック全体のステータス
        network_locked = os.path.exists(LOCK_STATUS_FILE)
        self.update_status_label('network_lock', network_locked)
        
        # NetPlan
        netplan_locked = False
        if os.path.exists('/etc/netplan'):
            result = subprocess.run(
                'find /etc/netplan -type f \\( -name "*.yaml" -o -name "*.yml" \\) -exec lsattr {} \\; 2>/dev/null | grep -q "i"',
                shell=True, capture_output=True
            )
            netplan_locked = (result.returncode == 0)
        self.update_status_label('netplan', netplan_locked)
        
        # NetworkManager
        nm_locked = os.path.exists('/etc/NetworkManager/conf.d/99-lock-settings.conf')
        self.update_status_label('networkmanager', nm_locked)
        
        # コマンド制限
        cmd_locked = os.path.exists('/etc/sudoers.d/network-lock')
        self.update_status_label('commands', cmd_locked)
        
        # インターフェース
        ifaces_locked = False
        if os.path.exists('/etc/network/interfaces.d'):
            result = subprocess.run(
                'find /etc/network/interfaces.d -type f -exec lsattr {} \\; 2>/dev/null | grep -q "i"',
                shell=True, capture_output=True
            )
            ifaces_locked = (result.returncode == 0)
        self.update_status_label('interfaces', ifaces_locked)
        
        # USB
        usb_locked = os.path.exists('/etc/modprobe.d/disable-usb-storage.conf')
        self.update_status_label('usb', usb_locked)
        
        # Bluetooth
        bt_locked = os.path.exists('/etc/modprobe.d/disable-bluetooth.conf')
        self.update_status_label('bluetooth', bt_locked)
        
        # Wi-Fi
        wifi_result = subprocess.run('rfkill list wifi 2>/dev/null | grep -q "blocked: yes"', 
                                    shell=True, capture_output=True)
        wifi_locked = (wifi_result.returncode == 0)
        self.update_status_label('wifi', wifi_locked)
        
        self.log_message("ステータス表示を更新しました", 'success')
    
    def update_status_label(self, key, is_locked):
        """ステータスラベルを更新"""
        label = self.status_labels.get(key)
        if label:
            if is_locked:
                label.config(text="✓ 有効", foreground='#27ae60')
            else:
                label.config(text="⊘ 無効", foreground='#f39c12')
    
    def show_help(self):
        """ヘルプを表示"""
        help_text = """
🔐 Ubuntu ネットワークロックマネージャー

【使い方】
1. ロックしたい機能のボタンをクリック
2. 「全てロック」で全ての機能を一度にロック
3. ステータス更新ボタンで最新状態を表示

【ロック機能】
• NetPlan - ネットワーク設定ファイルを不変化
• NetworkManager - 設定変更を制限
• コマンド制限 - ip, nmcli 等のコマンドをブロック
• インターフェース - ネットワーク IF 設定を保護
• USB - USB ストレージを無効化
• Bluetooth - Bluetooth を無効化
• Wi-Fi - Wi-Fi をブロック

【注意】
• root 権限が必要です (sudo で実行)
• 本番環境では慎重に使用してください
• ロック解除方法を確認しておいてください

【コマンドライン版】
network-lock-cli.sh も利用可能です
"""
        messagebox.showinfo("ヘルプ", help_text)


def main():
    """メイン関数"""
    # root 権限チェック（警告のみ）
    if os.geteuid() != 0:
        print("警告：root 権限で実行することをお勧めします")
        print("sudo python3 network-lock-gui.py")
        print("")
    
    root = tk.Tk()
    app = NetworkLockGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
