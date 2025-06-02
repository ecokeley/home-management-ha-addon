#!/bin/sh
echo "[Seat:*]
autologin-user=root
autologin-user-timeout=0" > /etc/lightdm/lightdm.conf
mkdir -p /root/.config/autostart
echo "[Desktop Entry]
Type=Application
Name=Chromium Kiosk
Exec=chromium-browser --kiosk --no-first-run --disable-infobars http://localhost:8123
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true" > /root/.config/autostart/chromium.desktop
chmod +x /root/.config/autostart/chromium.desktop
rc-update add lightdm default
rc-service lightdm start