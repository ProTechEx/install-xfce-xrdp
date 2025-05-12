#!/bin/bash

echo "== Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== Installing Xfce desktop =="
sudo apt install -y xfce4 xfce4-goodies

echo "== Installing xRDP server =="
sudo apt install -y xrdp

echo "== Setting up Xfce as default for xRDP =="
echo xfce4-session > ~/.xsession
sudo cp ~/.xsession /etc/skel/.xsession

echo "== Adding xrdp to ssl-cert group =="
sudo adduser xrdp ssl-cert

echo "== Restarting xrdp service =="
sudo systemctl restart xrdp

echo "== Enabling firewall rule for RDP port (3389) =="
if sudo ufw status | grep -q active; then
    sudo ufw allow 3389/tcp
    echo "UFW is active – RDP port allowed."
else
    echo "UFW not active – skipping firewall rule."
fi

echo "== Setting graphical target (optional) =="
sudo systemctl set-default graphical.target

echo "== All done! You can now connect via RDP to:"
hostname -I | awk '{print $1}'
