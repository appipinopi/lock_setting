#!/bin/bash

# Ubuntu Network Lock Manager - Quick Control (English)
# Simple interface to manage network lock status

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOCK_STATUS_FILE="/var/lock/network-lock.status"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MAIN_SCRIPT="$SCRIPT_DIR/network-lock.sh"

print_header() {
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Ubuntu Network Lock Manager${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
}

check_status() {
    if [ -f "$LOCK_STATUS_FILE" ]; then
        echo -e "${GREEN}✓ Network lock is ENABLED${NC}"
        echo ""
        echo "Lock Information:"
        grep "LOCK_TIME\|LOCKED_BY\|NETPLAN_LOCKED\|NETWORKMANAGER_LOCKED\|COMMANDS_RESTRICTED" "$LOCK_STATUS_FILE" | sed 's/^/  /'
        return 0
    else
        echo -e "${YELLOW}⊘ Network lock is DISABLED${NC}"
        return 1
    fi
}

show_menu() {
    echo ""
    echo "Options:"
    echo -e "  ${CYAN}1${NC}) Enable Network Lock"
    echo -e "  ${CYAN}2${NC}) Disable Network Lock"
    echo -e "  ${CYAN}3${NC}) Check Status"
    echo -e "  ${CYAN}4${NC}) Exit"
    echo ""
}

enable_lock() {
    echo -e "${YELLOW}Enabling network lock...${NC}"
    if [ -f "$MAIN_SCRIPT" ]; then
        sudo bash "$MAIN_SCRIPT"
    else
        echo -e "${RED}Error: network-lock.sh not found at $MAIN_SCRIPT${NC}"
        return 1
    fi
}

disable_lock() {
    echo -e "${YELLOW}Are you sure you want to disable network lock? (yes/no)${NC}"
    read -r confirm
    if [ "$confirm" = "yes" ]; then
        if [ -f "$MAIN_SCRIPT" ]; then
            sudo bash "$MAIN_SCRIPT" --unlock
        else
            echo -e "${RED}Error: network-lock.sh not found${NC}"
            return 1
        fi
    else
        echo "Cancelled."
    fi
}

main_menu() {
    while true; do
        clear
        print_header
        echo ""
        check_status
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1)
                enable_lock
                read -p "Press Enter to continue..."
                ;;
            2)
                disable_lock
                read -p "Press Enter to continue..."
                ;;
            3)
                check_status
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${CYAN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Check if running with proper permissions for status check
if [ "$1" = "--status" ]; then
    print_header
    check_status
    exit 0
fi

# Interactive menu mode
main_menu
