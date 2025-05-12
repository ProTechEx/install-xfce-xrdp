#!/bin/bash

echo "== [1/9] Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== [2/9] Installing Xfce desktop =="
sudo apt install -y xfce4 xfce4-goodies

echo "== [3/9] Installing xRDP server =="
sudo apt install -y xrdp

echo "== [4/9] Setting Xfce as default for xRDP =="
echo xfce4-session > ~/.xsession
sudo cp ~/.xsession /etc/skel/.xsession

echo "== [5/9] Setting Turkish ALT-Q (QWERTY) layout system-wide and for RDP =="
# Set Turkish QWERTY (Alt-Q) for console and X
sudo localectl set-keymap trq
sudo localectl set-x11-keymap tr pc105 trq

# Set Turkish Q in user and xRDP startup
echo "setxkbmap -layout tr -variant trq" >> ~/.xsession
sudo sed -i '/^startxfce4/i setxkbmap -layout tr -variant trq' /etc/xrdp/startwm.sh

echo "== [6/9] Adding xrdp to ssl-cert group =="
sudo adduser xrdp ssl-cert

echo "== [7/9] Restarting xRDP service =="
sudo systemctl restart xrdp

echo "== [8/9] Opening RDP port in firewall (if active) =="
if sudo ufw status | grep -q active; then
    sudo ufw allow 3389/tcp
    echo "UFW is active – RDP port 3389 opened."
else
    echo "UFW is not active – skipping firewall rule."
fi

echo "== [9/9] Setting graphical boot target =="
sudo systemctl set-default graphical.target

IP=$(hostname -I | awk '{print $1}')
echo
echo "== ✅ Setup complete. You can connect via RDP to: $IP =="
echo "== 🔁 Rebooting in 10 seconds... (Press CTRL+C to cancel) =="
sleep 10
sudo reboot
