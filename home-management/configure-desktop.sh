#!/bin/sh
echo "Starting containerized desktop..."

# Create X11 config for framebuffer
mkdir -p /etc/X11
cat > /etc/X11/xorg.conf << 'EOF'
Section "Device"
    Identifier "fbdev"
    Driver "fbdev"
    Option "fbdev" "/dev/fb0"
EndSection

Section "Screen"
    Identifier "screen"
    Device "fbdev"
EndSection
EOF

# Wait for X server
echo "Waiting for X server..."
while ! DISPLAY=:0 xset q >/dev/null 2>&1; do
    sleep 1
done

echo "X server ready, starting Chromium..."
export DISPLAY=:0

chromium-browser \
    --display=:0 \
    --kiosk \
    --no-first-run \
    --disable-infobars \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --remote-debugging-port=9222 \
    http://homeassistant.local:8123 &

# Keep script running
while true; do
    sleep 60
done