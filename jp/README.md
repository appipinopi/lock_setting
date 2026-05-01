# Ubuntu 24.04 LTS ネットワーク設定ロック

Ubuntuのネットワーク設定を不正な変更から保護する包括的なセキュリティツールです。

## 機能

✓ **NetPlan設定の保護** - ネットワーク設定ファイルを不変にします  
✓ **NetworkManager制限** - NetworkManager設定を制限します  
✓ **コマンドレベルの制御** - ネットワーク管理コマンドの実行を防止します  
✓ **インターフェース保護** - ネットワークインターフェース設定をロックします  
✓ **簡単な管理** - ロックの有効化/無効化が簡単なCLIツール  
✓ **ステータス監視** - ロック状態と履歴を追跡します  

## ファイル構成

```
network-lock/
├── en/
│   ├── network-lock.sh      # メインロック/アンロックスクリプト（英語版）
│   ├── lock-manager.sh      # インタラクティブマネージャー（英語版）
│   └── README.md
├── jp/
│   ├── network-lock.sh      # メインロック/アンロックスクリプト（日本語版）
│   ├── lock-manager.sh      # インタラクティブマネージャー（日本語版）
│   └── README.md
└── README.md
```

## クイックスタート

### 1. パーミッション設定

スクリプトを実行可能にします：

```bash
chmod +x en/network-lock.sh
chmod +x en/lock-manager.sh
chmod +x jp/network-lock.sh
chmod +x jp/lock-manager.sh
```

### 2. ネットワークロックを有効化

**インタラクティブマネージャーを使用（推奨）:**
```bash
sudo ./jp/lock-manager.sh
```

**直接コマンド:**
```bash
sudo ./jp/network-lock.sh
```

### 3. ロックステータスを確認

```bash
sudo ./jp/lock-manager.sh --status
```

### 4. ネットワークロックを無効化

**インタラクティブマネージャーを使用:**
```bash
sudo ./jp/lock-manager.sh
# オプション 2 を選択
```

**直接コマンド:**
```bash
sudo ./jp/network-lock.sh --unlock
```

## ロック対象

### 1. NetPlan設定
- すべてのYAMLファイルを不変にします（`chattr +i`）
- ディレクトリのパーミッションを制限します（700）
- ネットワークインターフェースの変更を防止します

### 2. NetworkManager設定
- 認証チェックを有効化します（auth-polkit）
- 制限的な設定を作成します
- デバイス管理設定をロックします

### 3. ネットワークコマンド
- sudoersルール経由で制限します
- ブロック対象コマンド:
  - `ip`
  - `ifconfig`
  - `nmcli`
  - `networkctl`
  - `systemctl`（ネットワークサービス）
  - `iptables` / `ip6tables`
  - `netplan`

### 4. インターフェースファイル
- `/etc/network/interfaces.d/*` ファイルを不変にします
- 直接的なインターフェース設定変更を防止します

## ロックステータスファイル

位置: `/var/lock/network-lock.status`

含まれる情報:
- ロック有効化状態
- ロックのタイムスタンプ
- ロックを適用したユーザー
- 個別コンポーネントのロック状態

## 重要な注意事項

⚠️ **Root権限が必要** - すべての操作は `sudo` が必要です  
⚠️ **サービス再起動** - NetworkManagerとnetworkingサービスが再起動します  
⚠️ **ロック解除に注意** - ロック解除は全保護を無効化します  
⚠️ **設定のバックアップ** - ロック前にネットワーク設定をバックアップしてください  

## トラブルシューティング

### 再起動後にファイルのロックが解除できない
不変フラグが残っている場合:
```bash
sudo chattr -i /etc/netplan/*.yaml
sudo chattr -i /etc/network/interfaces.d/*
```

### NetworkManagerが起動しない
元の設定に戻す:
```bash
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf
sudo systemctl restart NetworkManager
```

### sudoersロックが厳しすぎる
修正または削除:
```bash
sudo visudo -f /etc/sudoers.d/network-lock
```

## システム要件

- Ubuntu 24.04 LTS（22.04以上でも動作する可能性あり）
- Root/sudo アクセス権
- `chattr` コマンド（通常プリインストール）
- NetworkManager または netplan

## セキュリティのヒント

1. **テスト環境で試す** - 本番環境の前にテスト環境でロックをテストしてください
2. **変更を記録** - ロック適用時期を記録してください
3. **バックアップ** - ロック前にネットワーク設定をバックアップしてください
4. **最小限の原則** - 保護する必要があるもののみをロックしてください
5. **定期的な監査** - ロック状態を定期的に確認してください

## ライセンス

自己責任でご使用ください。本番環境への導入前に十分なテストを行ってください。

## サポート

問題が発生した場合:
1. ロック状態を確認: `sudo ./lock-manager.sh --status`
2. システムログを確認: `journalctl -u NetworkManager`
3. パーミッションを確認: `ls -la /etc/netplan/`
4. 不変フラグを確認: `lsattr /etc/netplan/*`
