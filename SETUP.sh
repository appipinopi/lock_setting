#!/bin/bash

# Network Lock Setup and Quick Start Guide

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_title() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Ubuntu Network Lock - Setup & Quick Guide     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

setup_permissions() {
    print_section "Setting up file permissions..."
    
    local en_dir="./en"
    local jp_dir="./jp"
    
    if [ -d "$en_dir" ]; then
        chmod +x "$en_dir/network-lock.sh" "$en_dir/lock-manager.sh" 2>/dev/null
        echo -e "${GREEN}✓${NC} English scripts are now executable"
    fi
    
    if [ -d "$jp_dir" ]; then
        chmod +x "$jp_dir/network-lock.sh" "$jp_dir/lock-manager.sh" 2>/dev/null
        echo -e "${GREEN}✓${NC} Japanese scripts are now executable"
    fi
}

show_quick_start() {
    print_section "Quick Start Commands"
    
    echo -e "${YELLOW}English Version:${NC}"
    echo -e "  Lock:    ${CYAN}sudo ./en/lock-manager.sh${NC}"
    echo -e "  Direct:  ${CYAN}sudo ./en/network-lock.sh${NC}"
    echo ""
    
    echo -e "${YELLOW}Japanese Version:${NC}"
    echo -e "  Lock:    ${CYAN}sudo ./jp/lock-manager.sh${NC}"
    echo -e "  Direct:  ${CYAN}sudo ./jp/network-lock.sh${NC}"
    echo ""
}

show_file_structure() {
    print_section "Directory Structure"
    
    if command -v tree &> /dev/null; then
        tree -L 2 2>/dev/null || ls -R
    else
        echo "network-lock/"
        echo "├── en/"
        echo "│   ├── network-lock.sh"
        echo "│   ├── lock-manager.sh"
        echo "│   └── README.md"
        echo "├── jp/"
        echo "│   ├── network-lock.sh"
        echo "│   ├── lock-manager.sh"
        echo "│   └── README.md"
        echo "└── SETUP.sh (this file)"
    fi
    echo ""
}

show_features() {
    print_section "Features Protected"
    
    echo -e "${GREEN}✓ NetPlan Configuration${NC}"
    echo "  → Makes .yaml files immutable"
    echo "  → Restricts directory permissions"
    echo ""
    
    echo -e "${GREEN}✓ NetworkManager Settings${NC}"
    echo "  → Applies authentication policies"
    echo "  → Restricts configuration changes"
    echo ""
    
    echo -e "${GREEN}✓ Network Commands${NC}"
    echo "  → Blocks: ip, ifconfig, nmcli, systemctl"
    echo "  → Prevents iptables/ip6tables changes"
    echo ""
    
    echo -e "${GREEN}✓ Interface Configurations${NC}"
    echo "  → Locks /etc/network/interfaces.d/*"
    echo "  → Prevents direct modifications"
    echo ""
}

show_usage_examples() {
    print_section "Usage Examples"
    
    echo -e "${YELLOW}Example 1: Enable Network Lock${NC}"
    echo "  $ sudo ./jp/lock-manager.sh"
    echo "  → Select option 1 from menu"
    echo ""
    
    echo -e "${YELLOW}Example 2: Check Lock Status${NC}"
    echo "  $ sudo ./jp/lock-manager.sh --status"
    echo ""
    
    echo -e "${YELLOW}Example 3: Disable Network Lock${NC}"
    echo "  $ sudo ./jp/lock-manager.sh"
    echo "  → Select option 2 from menu"
    echo ""
    
    echo -e "${YELLOW}Example 4: View Lock Information${NC}"
    echo "  $ cat /var/lock/network-lock.status"
    echo ""
}

show_safety_tips() {
    print_section "Safety & Best Practices"
    
    echo -e "${YELLOW}Before Locking:${NC}"
    echo "  1. Test in a non-critical environment first"
    echo "  2. Backup your current network configuration:"
    echo "     ${CYAN}sudo cp -r /etc/netplan ~/netplan-backup${NC}"
    echo "  3. Document your current network setup"
    echo ""
    
    echo -e "${YELLOW}After Locking:${NC}"
    echo "  1. Test network connectivity"
    echo "  2. Verify services are running:"
    echo "     ${CYAN}systemctl status networking${NC}"
    echo "  3. Monitor system logs:"
    echo "     ${CYAN}journalctl -u NetworkManager -f${NC}"
    echo ""
    
    echo -e "${YELLOW}Unlocking:${NC}"
    echo "  1. Keep unlock procedure documented"
    echo "  2. Test unlock in controlled environment"
    echo "  3. Have root/sudo access verified before locking"
    echo ""
}

show_troubleshooting() {
    print_section "Troubleshooting"
    
    echo -e "${YELLOW}Q: Scripts won't execute${NC}"
    echo -e "${CYAN}A: Make executable with:${NC}"
    echo "   sudo chmod +x ./en/*.sh ./jp/*.sh"
    echo ""
    
    echo -e "${YELLOW}Q: Immutable flags won't clear${NC}"
    echo -e "${CYAN}A: Manually remove with:${NC}"
    echo "   sudo chattr -i /etc/netplan/*.yaml"
    echo ""
    
    echo -e "${YELLOW}Q: NetworkManager won't restart${NC}"
    echo -e "${CYAN}A: Check logs and restore config:${NC}"
    echo "   sudo rm /etc/NetworkManager/conf.d/99-lock-settings.conf"
    echo "   sudo systemctl restart NetworkManager"
    echo ""
    
    echo -e "${YELLOW}Q: Can't run network commands${NC}"
    echo -e "${CYAN}A: Check sudoers lock rules:${NC}"
    echo "   sudo visudo -f /etc/sudoers.d/network-lock"
    echo ""
}

show_command_reference() {
    print_section "Command Reference"
    
    echo -e "${YELLOW}Lock/Unlock Operations:${NC}"
    echo "  Lock (interactive):      ${CYAN}sudo ./jp/lock-manager.sh${NC}"
    echo "  Lock (direct):           ${CYAN}sudo ./jp/network-lock.sh${NC}"
    echo "  Unlock (interactive):    ${CYAN}sudo ./jp/lock-manager.sh${NC} (option 2)"
    echo "  Unlock (direct):         ${CYAN}sudo ./jp/network-lock.sh --unlock${NC}"
    echo ""
    
    echo -e "${YELLOW}Status & Verification:${NC}"
    echo "  Check status:            ${CYAN}sudo ./jp/lock-manager.sh --status${NC}"
    echo "  View lock info:          ${CYAN}cat /var/lock/network-lock.status${NC}"
    echo "  List immutable files:    ${CYAN}lsattr /etc/netplan/*${NC}"
    echo "  Check permissions:       ${CYAN}ls -la /etc/netplan/${NC}"
    echo ""
    
    echo -e "${YELLOW}Diagnostics:${NC}"
    echo "  NetworkManager logs:     ${CYAN}journalctl -u NetworkManager${NC}"
    echo "  Network service logs:    ${CYAN}journalctl -u networking${NC}"
    echo "  System logs:             ${CYAN}journalctl -xe${NC}"
    echo ""
}

main() {
    print_title
    
    # Check if running in network-lock directory
    if [ ! -d "en" ] || [ ! -d "jp" ]; then
        echo -e "${RED}Error: Please run this script from the network-lock directory${NC}"
        exit 1
    fi
    
    setup_permissions
    echo ""
    
    show_quick_start
    show_file_structure
    show_features
    show_usage_examples
    show_safety_tips
    show_troubleshooting
    show_command_reference
    
    print_section "Setup Complete!"
    echo -e "${GREEN}✓ All scripts are ready to use${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Read the README: ${CYAN}cat en/README.md${NC} or ${CYAN}cat jp/README.md${NC}"
    echo "  2. Start with:      ${CYAN}sudo ./jp/lock-manager.sh${NC}"
    echo ""
    echo -e "${CYAN}For more info, check: en/README.md or jp/README.md${NC}"
    echo ""
}

main
