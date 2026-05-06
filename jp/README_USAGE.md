# Ubuntu ネットワークロックマネージャー - 使い方ガイド

## 📋 概要

このツールは Ubuntu システムのネットワーク設定や様々な機能を簡単にロック/アンロックできます。
GUI 版と CLI 版（CUI 版）の 2 つのインターフェースを提供します。

---

## 🚀 クイックスタート

### CLI 版（ターミナルで動作）

```bash
# インタラクティブモードで起動
sudo ./network-lock-cli.sh

# ステータス表示のみ
sudo ./network-lock-cli.sh --status

# 全機能をワンコマンドでロック
sudo ./network-lock-cli.sh --lock-all

# 全機能をワンコマンドで解除
sudo ./network-lock-cli.sh --unlock-all

# ヘルプ表示
sudo ./network-lock-cli.sh --help
```

### GUI 版（グラフィカルインターフェース）

```bash
# GUI 版を起動
sudo python3 network-lock-gui.py

# または
sudo ./network-lock-gui.py
```

---

## 🔒 ロックできる機能

| 機能 | 説明 | コマンドオプション |
|------|------|-------------------|
| **NetPlan** | ネットワーク設定ファイルを不変化 | `--lock-netplan` |
| **NetworkManager** | 設定変更を制限 | `--lock-nm` |
| **コマンド制限** | ip, nmcli 等のコマンドをブロック | `--lock-cmd` |
| **インターフェース** | ネットワーク IF 設定を保護 | (メニューから) |
| **USB ポート** | USB ストレージを無効化 | `--lock-usb` |
| **Bluetooth** | Bluetooth を無効化 | `--lock-bt` |
| **Wi-Fi** | Wi-Fi をブロック | `--lock-wifi` |
| **全て** | 上記すべてを一度にロック | `--lock-all` |

---

## 💻 CLI 版の使い方

### インタラクティブモード

```bash
sudo ./network-lock-cli.sh
```

メニューが表示され、番号を選択して操作します：

```
【機能選択メニュー】

  1) NetPlan 設定をロック
  2) NetworkManager をロック
  3) ネットワークコマンドを制限
  4) インターフェース設定をロック
  5) USB ポートをロック
  6) Bluetooth をロック
  7) Wi-Fi をロック
  8) 全てロック

  9) NetPlan ロック解除
  10) NetworkManager ロック解除
  ...
```

### コマンドラインオプション

```bash
# ステータス確認
sudo ./network-lock-cli.sh --status

# 個別ロック
sudo ./network-lock-cli.sh --lock-netplan
sudo ./network-lock-cli.sh --lock-nm
sudo ./network-lock-cli.sh --lock-cmd
sudo ./network-lock-cli.sh --lock-usb
sudo ./network-lock-cli.sh --lock-bt
sudo ./network-lock-cli.sh --lock-wifi

# 全てロック
sudo ./network-lock-cli.sh --lock-all

# 全て解除
sudo ./network-lock-cli.sh --unlock-all
```

### 使用例

```bash
# 1. 現在の状態を確認
sudo ./network-lock-cli.sh --status

# 2. ネットワーク設定をロック
sudo ./network-lock-cli.sh --lock-all

# 3. ロック後に確認
sudo ./network-lock-cli.sh --status

# 4. 必要に応じて解除
sudo ./network-lock-cli.sh --unlock-all
```

---

## 🖥️ GUI 版の使い方

### 起動方法

```bash
sudo python3 network-lock-gui.py
```

### 画面構成

1. **ヘッダー** - アプリケーションタイトル
2. **ステータス表示** - 各機能の現在のロック状態（✓有効 / ⊘無効）
3. **ロック機能ボタン** - 8 つのロック機能ボタン
4. **実行ログ** - 実行された操作のログ表示
5. **コントロールボタン** - 更新・ヘルプ・終了

### 操作方法

1. **ロックする**: ロックしたい機能のボタンをクリック
2. **全てロック**: 「全てロック」ボタンで全機能を一度にロック
3. **解除する**: 各機能または「全て解除」でロックを解除
4. **状態確認**: 「ステータス更新」ボタンで最新状態を表示

---

## ⚠️ 注意事項

### 重要

- **root 権限が必要** - 必ず `sudo` で実行してください
- **本番環境では慎重に** - テスト環境で十分にテストしてください
- **バックアップ推奨** - 重要な設定は事前にバックアップしてください
- **ロック解除方法の確認** - ロック前に解除方法を確認しておいてください

### ロック解除ができない場合

手動で解除する方法：

```bash
# NetPlan の不変フラグを削除
sudo chattr -i /etc/netplan/*.yaml

# NetworkManager 設定を削除
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf

# sudoers ルールを削除
sudo rm /etc/sudoers.d/network-lock

# USB ロックを解除
sudo rm /etc/modprobe.d/disable-usb-storage.conf

# Bluetooth ロックを解除
sudo rm /etc/modprobe.d/disable-bluetooth.conf
```

---

## 📊 ステータスファイル

ロック状態は以下のファイルに記録されます：

```
/var/lock/network-lock.status
```

内容例：
```
NETWORK_LOCK_ENABLED=true
LOCK_TIME=2024 年 05 月 06 日 12:30:45
LOCKED_BY=root
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
USB_LOCKED=true
BLUETOOTH_LOCKED=true
WIFI_LOCKED=true
```

---

## 🔧 トラブルシューティング

### GUI が起動しない

```bash
# tkinter がインストールされているか確認
python3 -c "import tkinter"

# インストールされていない場合
sudo apt-get install python3-tk
```

### 権限エラー

必ず `sudo` で実行してください：

```bash
# ❌ ダメ
./network-lock-cli.sh
python3 network-lock-gui.py

# ⭕ OK
sudo ./network-lock-cli.sh
sudo python3 network-lock-gui.py
```

### ネットワーク接続が失われた

```bash
# すぐに全ロックを解除
sudo ./network-lock-cli.sh --unlock-all

# または GUI 版で「全て解除」をクリック

# ネットワークサービスを再起動
sudo systemctl restart networking
sudo systemctl restart NetworkManager
```

---

## 📁 ファイル構成

```
jp/
├── network-lock-cli.sh      # CLI 版スクリプト
├── network-lock-gui.py      # GUI 版スクリプト
├── lock-manager.sh          # 既存のマネージャースクリプト
├── lock_network.sh          # 既存のロックスクリプト
└── README_USAGE.md          # このファイル
```

---

## 💡 ヒント

### 定期的な監視

```bash
# 5 秒ごとにステータスを表示
watch -n 5 'sudo ./network-lock-cli.sh --status'
```

### スクリプトのカスタマイズ

`network-lock-cli.sh` や `network-lock-gui.py` を編集して、
追加の機能をカスタマイズできます。

### ログの確認

```bash
# システムログでネットワーク関連のエラーを確認
journalctl -u NetworkManager -f

# 最近のエラーを確認
journalctl -xe
```

---

## 📞 サポート

問題が発生した場合は：

1. ステータス確認：`sudo ./network-lock-cli.sh --status`
2. システムログ確認：`journalctl -xe`
3. 手動解除：上記の「ロック解除ができない場合」を参照

---

## 📝 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

---

**安全にシステムを保護しましょう！ 🔐**
