#!/bin/bash

echo "== [1/7] Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== [2/7] Installing Xfce desktop =="
sudo apt install -y xfce4 xfce4-goodies

echo "== [3/7] Installing xRDP server =="
sudo apt install -y xrdp

echo "== [4/7] Setting Xfce as default for xRDP =="
echo xfce4-session > ~/.xsession
sudo cp ~/.xsession /etc/skel/.xsession

echo "== [5/7] Adding xrdp to ssl-cert group =="
sudo adduser xrdp ssl-cert

echo "== [6/7] Restarting xrdp service =="
sudo systemctl restart xrdp

echo "== [7/7] Setting keyboard layout to Turkish Q =="
# Set Turkish QWERTY system-wide for xRDP
sudo localectl set-x11-keymap tr pc105 trq
# Fallback to use it in remote sessions explicitly
echo "setxkbmap tr" >> ~/.xsession

echo "== Checking and updating firewall =="
if sudo ufw status | grep -q active; then
    sudo ufw allow 3389/tcp
    echo "UFW is active – RDP port 3389 opened."
else
    echo "UFW not active – skipping firewall rule."
fi

echo "== Optional: Set graphical target for future boots =="
sudo systemctl set-default graphical.target

echo
echo "== ✅ Setup complete. You can now connect via RDP to this IP: =="
hostname -I | awk '{print $1}'
