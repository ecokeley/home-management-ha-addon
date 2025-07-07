@echo off
set HA_IP=192.168.1.166
set SSH_KEY=%USERPROFILE%\.ssh\ha_key
set LOCAL_ADDON_DIR=.\home-management
set REMOTE_ADDON_DIR=/addons/home_management
set ADDON_SLUG=home_management

echo Cleaning up previous add-on files on %HA_IP%...
ssh -i "%SSH_KEY%" root@%HA_IP% "rm -rf %REMOTE_ADDON_DIR%"

echo Transferring add-on files to %HA_IP%:%REMOTE_ADDON_DIR%...
scp -i "%SSH_KEY%" -r "%LOCAL_ADDON_DIR%\*" "root@%HA_IP%:%REMOTE_ADDON_DIR%/"

echo Installing and starting the add-on on Home Assistant...
ssh -i "%SSH_KEY%" root@%HA_IP% "mkdir -p %REMOTE_ADDON_DIR% && ha supervisor restart && timeout 5 && ha addons reload && timeout 5 && ha addons install %ADDON_SLUG% && ha addons start %ADDON_SLUG%"

echo Verifying add-on status...
ssh -i "%SSH_KEY%" root@%HA_IP% "ha addons list && ha addons logs %ADDON_SLUG%"

echo Deployment complete. Check Home Assistant UI at http://192.168.1.166:8123