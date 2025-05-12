#!/bin/bash

set -e

echo "== [1/8] Updating system =="
apt update && apt upgrade -y

echo "== [2/8] Installing Ubuntu GNOME Desktop =="
DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-gnome-desktop gnome-session gdm3

echo "== [3/8] Installing xRDP =="
apt install -y xrdp xorgxrdp dbus-x11 x11-utils

echo "== [4/8] Allowing root login in xRDP =="
sed -i 's/^AllowRootLogin=.*/AllowRootLogin=true/' /etc/xrdp/sesman.ini

echo "== [5/8] Setting up root's GNOME session =="
cat <<EOF > /root/.xsession
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_SESSION_DESKTOP=ubuntu
export LANG=tr_TR.UTF-8
export LC_ALL=tr_TR.UTF-8
setxkbmap -layout tr -variant q
exec gnome-session
EOF

chmod +x /root/.xsession

echo "== [6/8] Setting Turkish Q keyboard layout system-wide =="
localectl set-keymap trq
localectl set-x11-keymap tr pc105 q
update-locale LANG=tr_TR.UTF-8
locale-gen tr_TR.UTF-8

echo "== [7/8] Updating xrdp startup script to load Turkish layout and GNOME session =="
cat <<EOF > /etc/xrdp/startwm.sh
#!/bin/sh
export LANG=tr_TR.UTF-8
export LC_ALL=tr_TR.UTF-8
setxkbmap -layout tr -variant q
. /etc/X11/Xsession
EOF

chmod +x /etc/xrdp/startwm.sh

echo "== [8/8] Restarting services and enabling graphical target =="
systemctl set-default graphical.target
systemctl restart xrdp xrdp-sesman

echo
echo "✅ All done. System will reboot in 10 seconds..."
sleep 10
reboot
