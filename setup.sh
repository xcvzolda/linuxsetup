#!/bin/bash

# Ensure the script is run with sudo/root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo: sudo ./setup.sh"
  exit 1
fi

echo "=================================================================="
echo "This utility was made to help setup Ubuntu Desktop dualbooting"
echo "!! WARNING !! This program installs remote access software"
echo "=================================================================="

# 1. Install remote.it agent
echo "Installing remote.it remote software..."
R3_REGISTRATION_CODE="26c9315c-e3c7-4bcb-8f6b-376082fb9b40" sh -c "$(curl -L https://downloads.remote.it/remoteit/install_agent.sh)"
echo "remote.it remote software installed."

# 2. Update system first (ensures dependencies and efibootmgr are up to date)
echo "Updating system..."
apt update && apt upgrade -y
apt install -y efibootmgr wget curl
echo "System updated."

# 3. Install Steam cleanly
echo "Now installing Steam..."
wget -O /tmp/steam.deb https://cdn.fastly.steamstatic.com/client/installer/steam.deb
apt install -y /tmp/steam.deb
rm -f /tmp/steam.deb
echo "Steam installed."

# 4. Configure UEFI Boot Order (Windows Priority + Ubuntu Selectable in Boot Menu)
echo "Configuring UEFI boot order for HP Laptop..."

# Find the 4-digit hex boot IDs for Windows and Ubuntu
WIN_ID=$(efibootmgr | grep -i "Windows Boot Manager" | grep -oE "Boot[0-9A-Fa-f]{4}" | sed 's/Boot//' | head -n 1)
UBUNTU_ID=$(efibootmgr | grep -i "ubuntu" | grep -oE "Boot[0-9A-Fa-f]{4}" | sed 's/Boot//' | head -n 1)

if [ -n "$WIN_ID" ] && [ -n "$UBUNTU_ID" ]; then
    # Ensure Ubuntu is marked active so it appears in the HP Boot Menu
    efibootmgr -b "$UBUNTU_ID" -a > /dev/null 2>&1
    
    # Get current boot order, strip out Windows and Ubuntu, and place Windows first, Ubuntu second
    CURRENT_ORDER=$(efibootmgr | grep "BootOrder:" | awk '{print $2}')
    OTHER_IDS=$(echo "$CURRENT_ORDER" | tr ',' '\n' | grep -v -E "^($WIN_ID|$UBUNTU_ID)$" | paste -sd, -)
    
    if [ -n "$OTHER_IDS" ]; then
        NEW_ORDER="$WIN_ID,$UBUNTU_ID,$OTHER_IDS"
    else
        NEW_ORDER="$WIN_ID,$UBUNTU_ID"
    fi
    
    efibootmgr -o "$NEW_ORDER"
    echo "SUCCESS: Windows ($WIN_ID) is set as primary boot. Ubuntu ($UBUNTU_ID) is active in the boot menu."
else
    echo "WARNING: Could not automatically detect both Windows and Ubuntu UEFI entries."
    echo "Current UEFI entries:"
    efibootmgr
fi

echo "=================================================================="
echo "SETUP COMPLETE!"
echo "NOTE FOR HP LAPTOP: Press ESC then F9 (or spam F9) at power-on"
echo "to open the Boot Menu and select Ubuntu (F12 is Network Boot on HP)."
echo "=================================================================="
