# Ubuntu 24.04 LTS Network Configuration Lock

A powerful, user-friendly security toolkit to lock and protect Ubuntu network settings from unauthorized modifications.

**Available Languages:** English(./en/README.md) | [日本語](./jp/README.md)

---

## Overview

This toolkit provides a complete solution for protecting Ubuntu network configurations at multiple levels:

- **File-Level Protection**: Makes configuration files immutable
- **Service-Level Control**: Restricts NetworkManager and networking services
- **Command-Level Enforcement**: Prevents execution of dangerous network commands
- **Easy Management**: Interactive menu-driven interface for lock management
- **Status Monitoring**: Track lock status and history

---

## Quick Start (30 seconds)

```bash
# 1. Navigate to the directory
cd network-lock

# 2. Run setup
bash SETUP.sh

# 3. Enable lock (Japanese version)
sudo ./jp/lock-manager.sh

# 4. Select option 1 from menu
```

Or use English:
```bash
sudo ./en/lock-manager.sh
```

---

## Directory Structure

```
network-lock/
├── README.md                    # This file
├── SETUP.sh                     # Setup and guide script
│
├── en/                          # English version
│   ├── network-lock.sh          # Main lock/unlock script
│   ├── lock-manager.sh          # Interactive manager
│   └── README.md                # Detailed English documentation
│
└── jp/                          # Japanese version
    ├── network-lock.sh          # Main lock/unlock script (日本語)
    ├── lock-manager.sh          # Interactive manager (日本語)
    └── README.md                # Detailed Japanese documentation (日本語)
```

---

## Features at a Glance

| Feature | Description |
|---------|-------------|
| **NetPlan Lock** | Makes network config files immutable |
| **NetworkManager Control** | Restricts configuration changes |
| **Command Blocking** | Prevents dangerous network commands |
| **Interface Protection** | Locks network interface files |
| **Interactive Manager** | User-friendly menu interface |
| **Status File** | Tracks lock status and timestamp |
| **Easy Unlock** | Simple unlock procedure |
| **Language Support** | English and Japanese |

---

## What Gets Protected

### 1. NetPlan Configuration
- Makes all `.yaml` and `.yml` files immutable
- Restricts directory permissions
- Prevents network interface modifications

**Protected Files:**
```
/etc/netplan/*.yaml
/etc/netplan/*.yml
```

### 2. NetworkManager
- Enforces authentication policies
- Creates restrictive configuration
- Controls device management

**Protected Config:**
```
/etc/NetworkManager/NetworkManager.conf
/etc/NetworkManager/conf.d/99-lock-settings.conf
```

### 3. Network Commands
These commands are restricted via sudoers:
- `ip` - Interface/routing management
- `ifconfig` - Interface configuration
- `nmcli` - NetworkManager CLI
- `networkctl` - systemd networking
- `systemctl` - Service control (network services)
- `iptables` / `ip6tables` - Firewall rules
- `netplan` - NetPlan management

### 4. Interface Files
- Makes files in `/etc/network/interfaces.d/` immutable
- Prevents direct interface configuration

---

## Usage

### For Interactive Users (Recommended)

```bash
# Lock network settings
sudo ./jp/lock-manager.sh
# Select option 1

# Check lock status
sudo ./jp/lock-manager.sh --status

# Unlock network settings
sudo ./jp/lock-manager.sh
# Select option 2
```

### For Command-Line Users

```bash
# Lock settings (direct)
sudo ./jp/network-lock.sh

# Unlock settings (direct)
sudo ./jp/network-lock.sh --unlock

# Check status
cat /var/lock/network-lock.status
```

### For English Users

Replace `jp/` with `en/` in all commands above.

---

## Installation

### Prerequisites

```bash
# Required on Ubuntu 24.04 LTS
- bash
- sudo access
- chattr (file attribute tool)
- NetworkManager or netplan
```

### Setup

```bash
# 1. Clone or download this repository
cd network-lock

# 2. Run setup script
bash SETUP.sh

# 3. Make scripts executable (automatic via SETUP.sh)
chmod +x en/*.sh jp/*.sh
```

---

## Examples

### Example 1: Protect a Production Server

```bash
# Backup current configuration
sudo cp -r /etc/netplan ~/netplan-backup

# Enable protection
sudo ./jp/lock-manager.sh
# Select 1

# Verify lock
sudo ./jp/lock-manager.sh --status

# Test network (should work normally)
ping 8.8.8.8
```

### Example 2: Temporary Protection During Maintenance

```bash
# Lock network settings
sudo ./jp/network-lock.sh

# Do your work...
# Services run, but cannot be modified

# When done, unlock
sudo ./jp/network-lock.sh --unlock
```

### Example 3: Audit Lock Status Regularly

```bash
# Create a monitoring script
while true; do
    clear
    sudo ./jp/lock-manager.sh --status
    sleep 300  # Check every 5 minutes
done
```

---

## Lock Status File

**Location:** `/var/lock/network-lock.status`

**Contents:**
```
NETWORK_LOCK_ENABLED=true
LOCK_TIME=2024-05-02 14:30:45
LOCKED_BY=root
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
```

---

## Important Warnings

⚠️ **Root Required**: All operations need `sudo` access

⚠️ **Service Restart**: Networking services will restart during lock

⚠️ **Network Downtime**: May cause brief network interruption

⚠️ **Application Compatibility**: Some apps might fail if they try to modify network settings

⚠️ **Test First**: Always test in non-critical environment first

---

## Troubleshooting

### Immutable Files Won't Unlock

```bash
# Manually clear immutable flags
sudo chattr -i /etc/netplan/*.yaml
sudo chattr -i /etc/network/interfaces.d/*
```

### NetworkManager Service Issues

```bash
# Restore original configuration
sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf

# Restart service
sudo systemctl restart NetworkManager

# Check status
systemctl status NetworkManager
```

### Command Still Executable

```bash
# Check sudoers rules
sudo visudo -f /etc/sudoers.d/network-lock

# Verify syntax
sudo visudo -c -f /etc/sudoers.d/network-lock
```

### Lost Network Connection

```bash
# Unlock network settings
sudo ./jp/network-lock.sh --unlock

# Restart networking
sudo systemctl restart networking

# Verify connectivity
ping 8.8.8.8
```

---

## Advanced Usage

### Custom Restriction Level

To modify restriction level, edit scripts:
- Add more commands to `NETWORK_CMDS` in sudoers
- Adjust file permissions (currently 700)
- Modify NetworkManager config settings

### Integration with Configuration Management

For Ansible/Puppet/Chef integration:
```bash
ansible-playbook -i inventory network-lock.yml
```

### Logging and Audit

```bash
# Check network service logs
journalctl -u NetworkManager -n 100

# Monitor lock file changes
watch -n 5 'ls -la /var/lock/network-lock.status'

# Audit command attempts
journalctl | grep -i "network\|netplan\|nmcli"
```

---

## Security Considerations

### What This Protects Against

✓ Accidental network misconfiguration  
✓ Unauthorized network changes  
✓ Configuration file tampering  
✓ Direct command-line network modifications  
✓ Service restarts that change configuration  

### What This Does NOT Protect Against

✗ Root user with sudo access (can always override)  
✗ Physical access to hardware  
✗ Kernel-level attacks  
✗ Firmware modifications  

### Recommended Additional Measures

1. **Use SELinux/AppArmor** for additional security
2. **Enable audit logging** for network changes
3. **Implement file integrity monitoring** (aide, tripwire)
4. **Use a configuration management tool** (Ansible, Puppet)
5. **Regular security audits** of permissions
6. **Keep system updated** with security patches

---

## Performance Impact

- **Memory**: Minimal (< 1MB)
- **CPU**: None during normal operation
- **Disk**: Minimal (< 10MB)
- **Network**: No impact on speed or latency

---

## Support & Documentation

### Quick Help

```bash
# View English documentation
cat en/README.md

# View Japanese documentation
cat jp/README.md

# Run setup guide
bash SETUP.sh
```

### Common Commands Cheatsheet

| Task | Command |
|------|---------|
| Lock (Interactive) | `sudo ./jp/lock-manager.sh` |
| Lock (Direct) | `sudo ./jp/network-lock.sh` |
| Unlock | `sudo ./jp/network-lock.sh --unlock` |
| Check Status | `sudo ./jp/lock-manager.sh --status` |
| View Lock Info | `cat /var/lock/network-lock.status` |
| Check Immutable Files | `lsattr /etc/netplan/*` |
| Remove Immutable Flag | `sudo chattr -i /path/to/file` |
| Set Immutable Flag | `sudo chattr +i /path/to/file` |

---

## Language Support

- **English**: `en/` directory with full documentation
- **Japanese**: `jp/` directory with 日本語 documentation

Both versions have identical functionality with localized messages and documentation.

---

## License & Disclaimer

This toolkit is provided as-is for security purposes. Users are responsible for:

- Testing thoroughly before production deployment
- Understanding the implications of locking network settings
- Maintaining backups of network configurations
- Having proper procedures for unlocking if needed

**Use at your own risk.**

---

## Contributing

To improve this toolkit:

1. Test extensively in your environment
2. Document any issues or suggestions
3. Verify compatibility with your Ubuntu version
4. Share feedback and improvements

---

## Version Information

- **Ubuntu Versions**: 24.04 LTS (tested), 22.04+ (likely compatible)
- **Bash Version**: 4.0+
- **Created**: 2024
- **Last Updated**: 2024

---

## Next Steps

1. **Read Setup**: Run `bash SETUP.sh`
2. **Review Documentation**: Check `jp/README.md` or `en/README.md`
3. **Test Safely**: Try in non-critical environment first
4. **Deploy Carefully**: Follow best practices when deploying
5. **Monitor Status**: Keep track of lock status

---

## Contact & Support

For issues or questions:

1. Check the README files in `en/` or `jp/`
2. Review troubleshooting section
3. Check system logs with `journalctl`
4. Verify permissions and flags with `lsattr` and `ls -la`

---

**Start securing your network settings today!**

```bash
sudo ./jp/lock-manager.sh
```

---

*Ubuntu is a registered trademark of Canonical Ltd.*
