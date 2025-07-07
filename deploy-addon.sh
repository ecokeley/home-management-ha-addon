#!/bin/bash

# Configuration
HA_IP="192.168.1.166"                   # Home Assistant IP address
SSH_KEY="$HOME/.ssh/ha_key"             # Path to SSH private key
LOCAL_ADDON_DIR="./home-management"     # Relative path to add-on directory
REMOTE_ADDON_DIR="/addons/home_management"  # Remote destination directory
ADDON_SLUG="home_management"            # Add-on slug from config.yaml

# Resolve absolute path for LOCAL_ADDON_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_ADDON_PATH="$SCRIPT_DIR/$LOCAL_ADDON_DIR"

# Validate local add-on directory
if [ ! -d "$LOCAL_ADDON_PATH" ]; then
  echo "Error: Local add-on directory '$LOCAL_ADDON_PATH' does not exist."
  exit 1
fi

# Validate required files
for file in config.yaml Dockerfile configure-desktop.sh; do
  if [ ! -f "$LOCAL_ADDON_PATH/$file" ]; then
    echo "Error: Required file '$file' not found in '$LOCAL_ADDON_PATH'."
    exit 1
  fi
done

# Step 1: Clean up previous files on Home Assistant
echo "Cleaning up previous add-on files on $HA_IP..."
ssh -i "$SSH_KEY" "root@$HA_IP" "rm -rf $REMOTE_ADDON_DIR"

# Step 2: Transfer add-on files to Home Assistant
echo "Transferring add-on files to $HA_IP:$REMOTE_ADDON_DIR..."
scp -i "$SSH_KEY" -r "$LOCAL_ADDON_PATH"/* "root@$HA_IP:$REMOTE_ADDON_DIR/"

# Step 3: SSH into Home Assistant and install/start the add-on
echo "Installing and starting the add-on on Home Assistant..."
ssh -i "$SSH_KEY" "root@$HA_IP" << EOF
  # Create remote directory if it doesn't exist
  mkdir -p "$REMOTE_ADDON_DIR"
  # Restart Supervisor to clear cache
  ha supervisor restart
  # Wait for Supervisor to restart
  sleep 5
  # Reload add-ons to detect local add-on
  ha addons reload
  # Wait for reload to complete
  sleep 5
  # Install the local add-on
  if ! ha addons install $ADDON_SLUG; then
    echo "Error: Failed to install add-on $ADDON_SLUG"
    ha logs | grep -i addon
    exit 1
  fi
  # Start the add-on
  if ! ha addons start $ADDON_SLUG; then
    echo "Error: Failed to start add-on $ADDON_SLUG"
    ha addons logs $ADDON_SLUG
    exit 1
  fi
EOF

# Step 4: Verify deployment
echo "Verifying add-on status..."
ssh -i "$SSH_KEY" "root@$HA_IP" << EOF
  echo "Listing add-ons..."
  ha addons list
  echo "Checking running processes..."
  ps aux | grep -E 'Xvfb|xfce4|chromium|lightdm' | grep -v grep
  echo "Checking add-on logs..."
  ha addons logs $ADDON_SLUG
EOF

echo "Deployment complete. Check the Home Assistant UI at http://192.168.1.166:8123 for the add-on status."