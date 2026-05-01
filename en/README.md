# Ubuntu 24.04 LTS Network Configuration Lock

A comprehensive security tool to lock and protect Ubuntu network settings from unauthorized changes.

## Features

✓ **NetPlan Configuration Protection** - Makes network configuration files immutable  
✓ **NetworkManager Restrictions** - Restricts NetworkManager settings  
✓ **Command-Level Control** - Prevents execution of network management commands  
✓ **Interface Protection** - Locks network interface configurations  
✓ **Easy Management** - Simple CLI tool to enable/disable locks  
✓ **Status Monitoring** - Track lock status and history  

## Files

```
network-lock/
├── en/
│   ├── network-lock.sh      # Main lock/unlock script (English)
│   ├── lock-manager.sh      # Interactive manager (English)
│   └── README.md
├── jp/
│   ├── network-lock.sh      # Main lock/unlock script (Japanese)
│   ├── lock-manager.sh      # Interactive manager (Japanese)
│   └── README.md
└── README.md
```

## Quick Start

### 1. Setup Permissions

Make scripts executable:

```bash
chmod +x en/network-lock.sh
chmod +x en/lock-manager.sh
chmod +x jp/network-lock.sh
chmod +x jp/lock-manager.sh
```

### 2. Enable Network Lock

**Using Interactive Manager (Recommended):**
```bash
sudo ./en/lock-manager.sh
# or for Japanese
sudo ./jp/lock-manager.sh
```

**Direct Command:**
```bash
sudo ./en/network-lock.sh
```

### 3. Check Lock Status

```bash
sudo ./en/lock-manager.sh --status
```

### 4. Disable Network Lock

**Using Interactive Manager:**
```bash
sudo ./en/lock-manager.sh
# Select option 2
```

**Direct Command:**
```bash
sudo ./en/network-lock.sh --unlock
```

## What Gets Locked

### 1. NetPlan Configuration
- Makes all YAML files immutable (`chattr +i`)
- Restricts directory permissions (700)
- Prevents modifications to network interfaces

### 2. NetworkManager Settings
- Enables authentication checks (auth-polkit)
- Creates restrictive configuration
- Locks device management settings

### 3. Network Commands
- Restricts via sudoers rules
- Blocked commands:
  - `ip`
  - `ifconfig`
  - `nmcli`
  - `networkctl`
  - `systemctl` (for network services)
  - `iptables` / `ip6tables`
  - `netplan`

### 4. Interface Files
- Makes `/etc/network/interfaces.d/*` files immutable
- Prevents direct interface configuration changes

## Lock Status File

Location: `/var/lock/network-lock.status`

Contains:
- Lock enabled status
- Lock timestamp
- User who applied the lock
- Individual component lock status

## Important Notes

⚠️ **Root Access Required** - All operations require `sudo`  
⚠️ **Service Restart** - NetworkManager and networking service will restart  
⚠️ **Careful Unlocking** - Unlocking disables all protections  
⚠️ **Backup Configs** - Consider backing up network configs before locking  

## Troubleshooting

### Cannot unlock files after reboot
If immutable flags remain after unlock:
```bash
sudo chattr -i /etc/netplan/*.yaml
sudo chattr -i /etc/network/interfaces.d/*
```

### NetworkManager won't start
Restore original config:
```bash
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf
sudo systemctl restart NetworkManager
```

### sudoers lock too restrictive
Modify or remove:
```bash
sudo visudo -f /etc/sudoers.d/network-lock
```

## System Requirements

- Ubuntu 24.04 LTS (should work on 22.04+)
- Root/sudo access
- `chattr` command (usually pre-installed)
- NetworkManager or netplan

## Safety Tips

1. **Test First** - Lock in test environment before production
2. **Document Changes** - Keep record of when locks are applied
3. **Backup** - Backup network configs before locking
4. **Minimal Principle** - Only lock what you need to protect
5. **Regular Audits** - Check lock status regularly

## License

Use at your own discretion. Test thoroughly before production deployment.

## Support

For issues:
1. Check lock status: `sudo ./lock-manager.sh --status`
2. Review system logs: `journalctl -u NetworkManager`
3. Verify permissions: `ls -la /etc/netplan/`
4. Check immutable flags: `lsattr /etc/netplan/*`
