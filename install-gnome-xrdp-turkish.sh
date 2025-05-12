#!/bin/bash

set -e

echo "== [1/9] Updating system =="
apt update && apt upgrade -y

echo "== [2/9] Installing Ubuntu GNOME Desktop =="
DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-gnome-desktop gnome-session gdm3

echo "== [3/9] Installing xRDP =="
apt install -y xrdp xorgxrdp dbus-x11 x11-utils

echo "== [4/9] Allowing root login in xRDP =="
sed -i 's/^AllowRootLogin=.*/AllowRootLogin=true/' /etc/xrdp/sesman.ini

echo "== [5/9] Creating root GNOME session with Turkish layout =="
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

echo "== [6/9] Setting Turkish Q layout and locale system-wide =="
localectl set-keymap trq
localectl set-x11-keymap tr pc105 q
locale-gen tr_TR.UTF-8
update-locale LANG=tr_TR.UTF-8

echo "== [7/9] Overriding xrdp startwm.sh for GNOME + Turkish layout =="
cat <<EOF > /etc/xrdp/startwm.sh
#!/bin/sh
export LANG=tr_TR.UTF-8
export LC_ALL=tr_TR.UTF-8
setxkbmap -layout tr -variant q
. /etc/X11/Xsession
EOF

chmod +x /etc/xrdp/startwm.sh

echo "== [8/9] Opening RDP port 3389 in firewall if UFW is active =="
if ufw status | grep -q active; then
  ufw allow 3389/tcp
  echo "✓ UFW is active — port 3389 opened."
else
  echo "⚠ UFW is not active — skipping firewall rule."
fi

echo "== [9/9] Restarting services and enabling graphical target =="
systemctl set-default graphical.target
systemctl restart xrdp xrdp-sesman

IP=$(hostname -I | awk '{print $1}')
echo
echo "✅ Setup complete. You can now connect via RDP to: $IP"
echo "🔁 Rebooting in 10 seconds..."
sleep 10
reboot
