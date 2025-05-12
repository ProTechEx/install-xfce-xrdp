#!/bin/bash

echo "== [1/8] Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== [2/8] Installing Xfce desktop =="
sudo apt install -y xfce4 xfce4-goodies

echo "== [3/8] Installing xRDP server =="
sudo apt install -y xrdp

echo "== [4/8] Setting Xfce as default for xRDP =="
echo xfce4-session > ~/.xsession
sudo cp ~/.xsession /etc/skel/.xsession

echo "== [5/8] Setting Turkish Alt-Q (QWERTY) keyboard layout system-wide =="
# Set keyboard layout for console and X11
sudo localectl set-keymap trq
sudo localectl set-x11-keymap tr pc105 trq

# Apply Turkish layout to xRDP sessions (add to startup)
echo "setxkbmap -layout tr -variant trq" >> ~/.xsession
sudo bash -c 'echo "setxkbmap -layout tr -variant trq" >> /etc/xrdp/startwm.sh'

echo "== [6/8] Adding xrdp to ssl-cert group =="
sudo adduser xrdp ssl-cert

echo "== [7/8] Restarting xrdp service =="
sudo systemctl restart xrdp

echo "== [8/8] Opening RDP port in firewall (if needed) =="
if sudo ufw status | grep -q active; then
    sudo ufw allow 3389/tcp
    echo "UFW is active – RDP port 3389 opened."
else
    echo "UFW not active – skipping firewall rule."
fi

echo "== Optional: Set graphical target for future boots =="
sudo systemctl set-default graphical.target

echo
echo "== ✅ Setup complete. Connect via RDP to: =="
hostname -I | awk '{print $1}'
