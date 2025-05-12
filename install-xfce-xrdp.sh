#!/bin/bash

echo "== [1/11] Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== [2/11] Installing XFCE desktop =="
sudo apt install -y xfce4 xfce4-goodies

echo "== [3/11] Installing xRDP and Xorg backend =="
sudo apt install -y xrdp xserver-xorg-core xorgxrdp

echo "== [4/11] Setting XFCE as default for xRDP =="
echo xfce4-session > ~/.xsession
sudo cp ~/.xsession /etc/skel/.xsession

echo "== [5/11] Setting Turkish Alt-Q keyboard layout system-wide =="
sudo localectl set-keymap trq
sudo localectl set-x11-keymap tr pc105 q
sudo update-locale LANG=tr_TR.UTF-8
sudo locale-gen tr_TR.UTF-8
sudo dpkg-reconfigure --frontend=noninteractive locales

echo "== [6/11] Configuring xRDP to fix Turkish character issues =="
sudo sed -i '/^\. \/etc\/X11\/Xsession/i \
export LANG=tr_TR.UTF-8\n\
export LC_ALL=tr_TR.UTF-8\n\
setxkbmap -layout tr -variant q' /etc/xrdp/startwm.sh

echo "== [7/11] Ensuring xRDP is using Xorg backend =="
# Replacing default xrdp.ini config with ensured Xorg support
sudo sed -i '/^\[Xorg\]/,/^\[/ s/^#//' /etc/xrdp/xrdp.ini
# Optional: move Xorg to top if needed

echo "== [8/11] Adding xrdp to ssl-cert group =="
sudo adduser xrdp ssl-cert

echo "== [9/11] Restarting xRDP service =="
sudo systemctl restart xrdp

echo "== [10/11] Allowing RDP port through UFW (if active) =="
if sudo ufw status | grep -q active; then
    sudo ufw allow 3389/tcp
    echo "UFW is active – RDP port 3389 opened."
else
    echo "UFW is not active – skipping firewall rule."
fi

echo "== [11/11] Setting system to boot into GUI =="
sudo systemctl set-default graphical.target

IP=$(hostname -I | awk '{print $1}')
echo
echo "✅ Setup complete. Connect via RDP to: $IP"
echo "🔁 Rebooting in 10 seconds to apply all changes..."
sleep 10
sudo reboot
