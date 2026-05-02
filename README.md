# Ubuntu Network Lock - System Configuration Protection Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange)](https://ubuntu.com)
[![Bash 4.0+](https://img.shields.io/badge/Bash-4.0%2B-blue)](https://www.gnu.org/software/bash/)
[![Status: Production Ready](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)](https://github.com/appipinopi/lock_setting)

🔐 A comprehensive security toolkit to lock and protect Ubuntu network settings from unauthorized modifications.

**Languages**: [English](#english) | [日本語](#日本語)

---

## English

### Overview

`lock_setting` provides multiple layers of network configuration protection:

- **File-Level Protection** - Makes configuration files immutable
- **Service-Level Control** - Restricts NetworkManager and networking services  
- **Command-Level Enforcement** - Blocks execution of dangerous network commands
- **Status Monitoring** - Track lock status and audit trail
- **Easy Management** - Interactive menu or direct command control

### Features

| Feature | Details |
|---------|---------|
| 🔒 **NetPlan Protection** | Makes network config files immutable with `chattr` |
| 🛡️ **NetworkManager Control** | Restricts configuration changes via auth-polkit |
| 🚫 **Command Blocking** | Prevents `ip`, `ifconfig`, `nmcli`, `netplan`, etc. |
| 📁 **Interface Locking** | Protects `/etc/network/interfaces.d/` files |
| 📊 **Status Tracking** | Creates audit trail in `/var/lock/network-lock.status` |
| 🎯 **Simple Interface** | Interactive menu (`lock-manager.sh`) for easy use |
| 🌍 **Multi-Language** | English and Japanese support |

### Quick Start

```bash
# Clone the repository
git clone https://github.com/appipinopi/lock_setting.git
cd lock_setting

# Make scripts executable
chmod +x bin/*.sh

# Run setup guide
bash setup.sh

# Enable network lock (interactive menu)
sudo ./bin/lock-manager.sh

# Or enable directly
sudo ./bin/network-lock.sh
```

### Usage

#### Interactive Mode (Recommended)

```bash
# Display menu and manage locks
sudo ./bin/lock-manager.sh

# Check lock status only
sudo ./bin/lock-manager.sh --status
```

#### Command Line Mode

```bash
# Enable lock
sudo ./bin/network-lock.sh

# Disable lock
sudo ./bin/network-lock.sh --unlock

# Check status
cat /var/lock/network-lock.status
```

### What Gets Protected

#### 1. NetPlan Configuration
```
/etc/netplan/*.yaml
/etc/netplan/*.yml
```
- Made immutable with `chattr +i`
- Directory permissions restricted to 700
- Prevents network interface modifications

#### 2. NetworkManager
```
/etc/NetworkManager/NetworkManager.conf
/etc/NetworkManager/conf.d/99-lock-settings.conf
```
- Authentication policies enforced
- Restrictive configurations applied
- Device management controlled

#### 3. Network Commands (via sudoers)
```
ip              - Interface/routing management
ifconfig        - Legacy interface configuration
nmcli           - NetworkManager CLI
networkctl      - systemd networking control
systemctl       - Service management (network services)
iptables        - IPv4 firewall rules
ip6tables       - IPv6 firewall rules
netplan         - NetPlan configuration tool
```

#### 4. Interface Files
```
/etc/network/interfaces.d/*
```
- Made immutable to prevent direct modifications

### Installation

#### Requirements

- Ubuntu 24.04 LTS (tested)
- Ubuntu 22.04 LTS (compatible)
- Ubuntu 20.04 LTS (likely compatible)
- Root/sudo access
- `chattr` command (pre-installed on Ubuntu)
- NetworkManager or netplan

#### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/appipinopi/lock_setting.git
cd lock_setting

# 2. Review documentation
cat README.md
cat docs/INSTALL.md

# 3. Make scripts executable (if needed)
chmod +x bin/*.sh setup.sh

# 4. Run setup
bash setup.sh

# 5. Test in non-critical environment
sudo ./bin/lock-manager.sh --status
```

### Examples

#### Example 1: Protect Production Server

```bash
# Backup current configuration
sudo cp -r /etc/netplan ~/netplan-backup.$(date +%Y%m%d)

# Enable protection
sudo ./bin/lock-manager.sh
# Select: 1) Enable Network Lock

# Verify lock
sudo ./bin/lock-manager.sh --status

# Test connectivity
ping 8.8.8.8
```

#### Example 2: Temporary Protection

```bash
# Lock immediately
sudo ./bin/network-lock.sh

# Do maintenance work
# Services run but cannot be modified

# Unlock when done
sudo ./bin/network-lock.sh --unlock
```

#### Example 3: Monitor Lock Status

```bash
# One-time check
sudo ./bin/lock-manager.sh --status

# Continuous monitoring
watch -n 5 'sudo ./bin/lock-manager.sh --status'

# View lock file
cat /var/lock/network-lock.status
```

### Lock Status File

Location: `/var/lock/network-lock.status`

```
NETWORK_LOCK_ENABLED=true
LOCK_TIME=2024-05-02 14:30:45
LOCKED_BY=root
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
```

### Troubleshooting

#### Immutable Files Won't Unlock

```bash
# Manually clear immutable flags
sudo chattr -i /etc/netplan/*.yaml
sudo chattr -i /etc/network/interfaces.d/*
```

#### NetworkManager Won't Start

```bash
# Restore original config
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf

# Restart service
sudo systemctl restart NetworkManager

# Verify status
systemctl status NetworkManager
```

#### Command Still Executable

```bash
# Check sudoers rules
sudo visudo -f /etc/sudoers.d/network-lock

# Verify syntax
sudo visudo -c -f /etc/sudoers.d/network-lock
```

#### Lost Network Connection

```bash
# Unlock immediately
sudo ./bin/network-lock.sh --unlock

# Restart networking
sudo systemctl restart networking

# Test connectivity
ping 8.8.8.8
```

### Documentation

- **README.md** - This file (English overview)
- **README_JP.md** - Japanese documentation
- **docs/INSTALL.md** - Detailed installation guide
- **docs/USAGE.md** - Comprehensive usage guide
- **docs/TROUBLESHOOTING.md** - Troubleshooting guide
- **docs/SECURITY.md** - Security considerations
- **docs/API.md** - Script API documentation

### Scripts

Located in `bin/` directory:

- **network-lock.sh** - Main lock/unlock script
- **lock-manager.sh** - Interactive management menu
- **setup.sh** - One-time setup script

### Configuration

Edit `bin/network-lock.sh` to customize:

```bash
# Restrict additional commands
# Add to NETWORK_CMDS in sudoers section

# Change permission levels
# Modify chmod values in scripts

# Exclude specific files
# Update find patterns
```

### Security Considerations

#### What This Protects Against

✅ Accidental network misconfiguration  
✅ Unauthorized network changes  
✅ Configuration file tampering  
✅ Direct command-line modifications  
✅ Service restarts that change config  

#### What This Does NOT Protect Against

❌ Root user with sudo access (can override)  
❌ Physical hardware access  
❌ Kernel-level attacks  
❌ Firmware modifications  
❌ Determined attackers with local access  

#### Recommendations

1. **Use alongside SELinux/AppArmor** for additional security
2. **Enable audit logging** for network changes
3. **Implement file integrity monitoring** (aide, tripwire)
4. **Use configuration management** (Ansible, Puppet, Chef)
5. **Regular security audits** of permissions
6. **Keep system updated** with security patches
7. **Monitor logs** regularly: `journalctl -u NetworkManager`

### Performance Impact

- **Memory**: < 1 MB
- **CPU**: Minimal (only during lock/unlock)
- **Disk**: < 10 MB
- **Network**: No impact on speed or latency

### Compatibility

| System | Status | Notes |
|--------|--------|-------|
| Ubuntu 24.04 LTS | ✅ Tested | Fully supported |
| Ubuntu 22.04 LTS | ✅ Likely | High compatibility |
| Ubuntu 20.04 LTS | ⚠️ Likely | Requires netplan |
| Debian 12+ | ⚠️ Likely | May need adjustments |
| Pop!_OS | ✅ Likely | Ubuntu-based |
| Elementary OS | ✅ Likely | Ubuntu-based |

### Contributing

Contributions are welcome! Please:

1. Test thoroughly in your environment
2. Document your changes
3. Follow existing code style
4. Submit pull requests with detailed descriptions
5. Include relevant issue references

### License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

### Disclaimer

⚠️ Use at your own risk. This tool modifies system-level security settings.

- Always test in non-critical environment first
- Backup your network configuration before use
- Understand the implications of locking network settings
- Have proper procedures for unlocking if needed
- Be prepared for potential network downtime

### Support

For issues, questions, or suggestions:

1. Check the documentation in `docs/`
2. Review troubleshooting section above
3. Check system logs: `journalctl -xe`
4. Open an issue on GitHub

### Roadmap

- [ ] Add LUKS encryption support
- [ ] Enhanced logging and audit trail
- [ ] Web dashboard for monitoring
- [ ] Ansible playbook integration
- [ ] Prometheus metrics export
- [ ] Additional language support

### Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## 日本語

### 概要

`lock_setting` は複数のレイヤーでネットワーク設定を保護します：

- **ファイルレベルの保護** - 設定ファイルを不変にする
- **サービスレベルの制御** - NetworkManagerとネットワークサービスを制限
- **コマンドレベルの実行制限** - 危険なネットワークコマンドをブロック
- **ステータス監視** - ロック状態と監査証跡を追跡
- **簡単な管理** - インタラクティブメニューまたは直接コマンド制御

### 機能

| 機能 | 詳細 |
|------|------|
| 🔒 **NetPlan保護** | `chattr` でネットワーク設定ファイルを不変に |
| 🛡️ **NetworkManager制御** | auth-polkitで設定変更を制限 |
| 🚫 **コマンドブロック** | `ip`, `ifconfig`, `nmcli`, `netplan` など実行制限 |
| 📁 **インターフェースロック** | `/etc/network/interfaces.d/` ファイルを保護 |
| 📊 **ステータス追跡** | `/var/lock/network-lock.status` に監査証跡を作成 |
| 🎯 **シンプルインターフェース** | インタラクティブメニュー（`lock-manager.sh`） |
| 🌍 **多言語対応** | 英語と日本語をサポート |

### クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/appipinopi/lock_setting.git
cd lock_setting

# スクリプトを実行可能に
chmod +x bin/*.sh

# セットアップガイドを実行
bash setup.sh

# ネットワークロックを有効化（インタラクティブメニュー）
sudo ./bin/lock-manager.sh

# または直接有効化
sudo ./bin/network-lock.sh
```

### 使用方法

#### インタラクティブモード（推奨）

```bash
# メニューを表示してロック管理
sudo ./bin/lock-manager.sh

# ロック状態のみ確認
sudo ./bin/lock-manager.sh --status
```

#### コマンドラインモード

```bash
# ロック有効化
sudo ./bin/network-lock.sh

# ロック無効化
sudo ./bin/network-lock.sh --unlock

# ステータス確認
cat /var/lock/network-lock.status
```

### 保護される項目

#### 1. NetPlan設定
```
/etc/netplan/*.yaml
/etc/netplan/*.yml
```
- `chattr +i` で不変に設定
- ディレクトリパーミッションを700に制限
- ネットワークインターフェースの変更を防止

#### 2. NetworkManager
```
/etc/NetworkManager/NetworkManager.conf
/etc/NetworkManager/conf.d/99-lock-settings.conf
```
- 認証ポリシーを実施
- 制限的な設定を適用
- デバイス管理を制御

#### 3. ネットワークコマンド（sudoersで制限）
```
ip              - インターフェース/ルーティング管理
ifconfig        - レガシーインターフェース設定
nmcli           - NetworkManager CLI
networkctl      - systemdネットワーク制御
systemctl       - サービス管理（ネットワークサービス）
iptables        - IPv4ファイアウォールルール
ip6tables       - IPv6ファイアウォールルール
netplan         - Netplan設定ツール
```

#### 4. インターフェースファイル
```
/etc/network/interfaces.d/*
```
- 直接変更を防ぐため不変に設定

### インストール

#### 必要な環境

- Ubuntu 24.04 LTS（テスト済み）
- Ubuntu 22.04 LTS（互換性あり）
- Ubuntu 20.04 LTS（互換性あり可能性）
- Root/sudoアクセス
- `chattr` コマンド（Ubuntuにプリインストール）
- NetworkManager または netplan

#### インストール手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/appipinopi/lock_setting.git
cd lock_setting

# 2. ドキュメントを確認
cat README_JP.md
cat docs/INSTALL.md

# 3. スクリプトを実行可能に（必要に応じて）
chmod +x bin/*.sh setup.sh

# 4. セットアップを実行
bash setup.sh

# 5. 非本番環境でテスト
sudo ./bin/lock-manager.sh --status
```

### 例

#### 例1: 本番サーバーの保護

```bash
# 現在の設定をバックアップ
sudo cp -r /etc/netplan ~/netplan-backup.$(date +%Y%m%d)

# 保護を有効化
sudo ./bin/lock-manager.sh
# 選択: 1) ネットワークロックを有効化

# ロック状態を確認
sudo ./bin/lock-manager.sh --status

# 接続をテスト
ping 8.8.8.8
```

#### 例2: 一時的な保護

```bash
# すぐにロック
sudo ./bin/network-lock.sh

# メンテナンス作業を実施
# サービスは実行されるが変更はできない

# 完了時にアンロック
sudo ./bin/network-lock.sh --unlock
```

#### 例3: ロック状態を監視

```bash
# ワンタイムチェック
sudo ./bin/lock-manager.sh --status

# 継続的に監視
watch -n 5 'sudo ./bin/lock-manager.sh --status'

# ロックファイルを表示
cat /var/lock/network-lock.status
```

### ロック状態ファイル

位置: `/var/lock/network-lock.status`

```
NETWORK_LOCK_ENABLED=true
LOCK_TIME=2024-05-02 14:30:45
LOCKED_BY=root
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
```

### トラブルシューティング

#### アンロック後も不変フラグが残っている

```bash
# 不変フラグを手動で削除
sudo chattr -i /etc/netplan/*.yaml
sudo chattr -i /etc/network/interfaces.d/*
```

#### NetworkManagerが起動しない

```bash
# 元の設定に復元
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf

# サービスを再起動
sudo systemctl restart NetworkManager

# ステータスを確認
systemctl status NetworkManager
```

#### コマンドが実行可能のままである

```bash
# sudoersルールを確認
sudo visudo -f /etc/sudoers.d/network-lock

# 構文を確認
sudo visudo -c -f /etc/sudoers.d/network-lock
```

#### ネットワーク接続が失われた

```bash
# すぐにアンロック
sudo ./bin/network-lock.sh --unlock

# ネットワークサービスを再起動
sudo systemctl restart networking

# 接続をテスト
ping 8.8.8.8
```

### ドキュメント

- **README.md** - 英語の概要
- **README_JP.md** - 日本語ドキュメント（このファイル）
- **docs/INSTALL.md** - 詳細インストールガイド
- **docs/USAGE.md** - 包括的な使用ガイド
- **docs/TROUBLESHOOTING.md** - トラブルシューティングガイド
- **docs/SECURITY.md** - セキュリティに関する考慮事項
- **docs/API.md** - スクリプトAPI文書

### セキュリティに関する考慮事項

#### 保護対象

✅ 不注意によるネットワーク設定変更  
✅ 不正なネットワーク変更  
✅ 設定ファイルの改ざん  
✅ コマンドラインからの直接修正  
✅ 設定を変更するサービス再起動  

#### 保護対象外

❌ sudo アクセスを持つ root ユーザー（オーバーライド可能）  
❌ 物理的なハードウェアアクセス  
❌ カーネルレベルの攻撃  
❌ ファームウェア修正  
❌ ローカルアクセスを持つ決定的な攻撃者  

#### 推奨事項

1. **SELinux/AppArmor と併用** して追加セキュリティを実装
2. **監査ログを有効化** してネットワーク変更を記録
3. **ファイルインテグリティ監視** (aide, tripwire) を実装
4. **設定管理ツール** (Ansible, Puppet, Chef) を使用
5. **定期的なセキュリティ監査** を実施
6. **システムをアップデート** してセキュリティパッチを適用
7. **ログを定期的に監視**: `journalctl -u NetworkManager`

### パフォーマンス影響

- **メモリ**: < 1 MB
- **CPU**: 最小限（ロック/アンロック時のみ）
- **ディスク**: < 10 MB
- **ネットワーク**: 速度またはレイテンシへの影響なし

### 互換性

| システム | ステータス | 備考 |
|---------|-----------|------|
| Ubuntu 24.04 LTS | ✅ テスト済み | 完全対応 |
| Ubuntu 22.04 LTS | ✅ 互換性あり | 高い互換性 |
| Ubuntu 20.04 LTS | ⚠️ 互換性あり | netplan必須 |
| Debian 12+ | ⚠️ 互換性あり | 調整が必要な可能性 |
| Pop!_OS | ✅ 互換性あり | Ubuntu ベース |
| Elementary OS | ✅ 互換性あり | Ubuntu ベース |

### ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

### 免責事項

⚠️ 自己責任でご使用ください。このツールはシステムレベルのセキュリティ設定を変更します。

- 本番環境の前に必ず非本番環境でテストしてください
- 使用前にネットワーク設定をバックアップしてください
- ネットワーク設定をロックすることの影響を理解してください
- ロック解除のための適切な手順を準備してください
- ネットワークダウンタイムの可能性に備えてください

### サポート

問題、質問、提案については：

1. `docs/` のドキュメントを確認
2. 上記のトラブルシューティングセクションを確認
3. システムログを確認: `journalctl -xe`
4. GitHub に issue を開く

### ロードマップ

- [ ] LUKS暗号化サポートを追加
- [ ] ロギングと監査証跡の強化
- [ ] 監視用Webダッシュボード
- [ ] Ansible playbook 統合
- [ ] Prometheus メトリクスエクスポート
- [ ] 追加言語サポート

### 変更履歴

バージョン履歴については [CHANGELOG.md](CHANGELOG.md) を参照してください。

---

## Stars & Support

If you find this project useful, please consider giving it a ⭐ on GitHub!

---

**Made with ❤️ for system administrators and security enthusiasts**
