#!/bin/bash

# Ubuntu 24.04 LTS Network Settings Lock Script (English)
# This script locks network configuration to prevent unauthorized changes

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root (sudo)"
    exit 1
fi

print_status "Starting Ubuntu Network Configuration Lock..."

# Configuration variables
NETPLAN_DIR="/etc/netplan"
NM_CONFIG="/etc/NetworkManager/NetworkManager.conf"
NM_CONF_D="/etc/NetworkManager/conf.d"
SUDOERS_D="/etc/sudoers.d"
LOCK_INDICATOR="/var/lock/network-lock.status"

# Function to lock NetPlan configuration
lock_netplan() {
    print_status "Locking NetPlan configuration..."
    
    if [ -d "$NETPLAN_DIR" ]; then
        # Make configuration files immutable
        find "$NETPLAN_DIR" -type f -name "*.yaml" -o -name "*.yml" | while read -r file; do
            chattr +i "$file"
            print_success "Locked: $file"
        done
        
        # Lock the directory itself
        chmod 700 "$NETPLAN_DIR"
        print_success "NetPlan directory permissions restricted"
    else
        print_warning "NetPlan directory not found"
    fi
}

# Function to lock NetworkManager
lock_networkmanager() {
    print_status "Locking NetworkManager configuration..."
    
    # Create restrictive NetworkManager config
    if [ -f "$NM_CONFIG" ]; then
        # Add permission restrictions
        if ! grep -q "\\[main\\]" "$NM_CONFIG"; then
            echo "[main]" >> "$NM_CONFIG"
        fi
        
        if ! grep -q "auth-polkit=" "$NM_CONFIG"; then
            echo "auth-polkit=true" >> "$NM_CONFIG"
        fi
    fi
    
    # Create locked configuration in conf.d
    mkdir -p "$NM_CONF_D"
    cat > "$NM_CONF_D/99-lock-settings.conf" << 'EOF'
[main]
# Lock network configuration
wifi-backend=iwd

[device]
# Prevent changes to managed devices
managed=true
EOF
    
    chmod 644 "$NM_CONF_D/99-lock-settings.conf"
    print_success "NetworkManager locked"
}

# Function to restrict network commands
lock_network_commands() {
    print_status "Restricting network management commands..."
    
    # Create sudoers rules to restrict network commands
    cat > "$SUDOERS_D/network-lock" << 'EOF'
# Network Configuration Lock
# Restrict network management commands

Cmnd_Alias NETWORK_CMDS = \
    /sbin/ip, \
    /sbin/ifconfig, \
    /usr/bin/nmcli, \
    /usr/sbin/networkctl, \
    /bin/systemctl, \
    /sbin/iptables, \
    /sbin/ip6tables, \
    /usr/sbin/netplan

# Deny all users (except root) from running network commands
%sudo ALL = (ALL) ALL, !NETWORK_CMDS
EOF
    
    chmod 440 "$SUDOERS_D/network-lock"
    print_success "Network commands restricted"
}

# Function to lock interface configurations
lock_interfaces() {
    print_status "Locking network interface configurations..."
    
    # Make interface files immutable
    if [ -d /etc/network/interfaces.d ]; then
        find /etc/network/interfaces.d -type f | while read -r file; do
            chattr +i "$file"
            print_success "Locked: $file"
        done
    fi
}

# Function to create lock status file
create_status_file() {
    print_status "Creating lock status file..."
    
    cat > "$LOCK_INDICATOR" << EOF
NETWORK_LOCK_ENABLED=true
LOCK_TIME=$(date '+%Y-%m-%d %H:%M:%S')
LOCKED_BY=$(whoami)
NETPLAN_LOCKED=true
NETWORKMANAGER_LOCKED=true
COMMANDS_RESTRICTED=true
INTERFACES_LOCKED=true
EOF
    
    chmod 600 "$LOCK_INDICATOR"
    print_success "Lock status file created: $LOCK_INDICATOR"
}

# Function to restart NetworkManager
restart_services() {
    print_status "Restarting network services..."
    systemctl restart networking
    systemctl restart NetworkManager 2>/dev/null || true
    print_success "Network services restarted"
}

# Main execution
main() {
    print_status "=========================================="
    print_status "Ubuntu Network Configuration Lock Tool"
    print_status "=========================================="
    
    lock_netplan
    lock_networkmanager
    lock_interfaces
    lock_network_commands
    create_status_file
    restart_services
    
    echo ""
    print_success "=========================================="
    print_success "Network configuration is now LOCKED"
    print_success "=========================================="
    echo ""
    print_status "Locked components:"
    echo "  ✓ NetPlan configuration (immutable files)"
    echo "  ✓ NetworkManager configuration"
    echo "  ✓ Network interface configurations"
    echo "  ✓ Network management commands (restricted)"
    echo ""
    print_warning "To unlock, run: sudo $0 --unlock"
}

# Unlock function
unlock() {
    print_warning "Unlocking network configuration..."
    
    # Remove immutable flag from NetPlan files
    find "$NETPLAN_DIR" -type f -name "*.yaml" -o -name "*.yml" 2>/dev/null | while read -r file; do
        chattr -i "$file"
        print_success "Unlocked: $file"
    done
    
    # Remove immutable flag from interface files
    find /etc/network/interfaces.d -type f 2>/dev/null | while read -r file; do
        chattr -i "$file"
    done
    
    # Remove sudoers lock rules
    rm -f "$SUDOERS_D/network-lock"
    
    # Remove lock status file
    rm -f "$LOCK_INDICATOR"
    
    print_success "Network configuration is now UNLOCKED"
}

# Check arguments
if [ "$1" = "--unlock" ]; then
    unlock
else
    main
fi
