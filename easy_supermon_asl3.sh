#!/bin/bash

#
# check if root
#
SUDO=""
if [[ $EUID != 0 ]]; then
    SUDO="sudo"
    SUDO_EUID=$(${SUDO} id -u)
    if [[ ${SUDO_EUID} -ne 0 ]]; then
        echo "This script must be run as root or with sudo"
        exit 1
    fi
fi

# Install Supermon 7.4
echo "Installing Supermon 7.4..."
cd /usr/local/sbin
sudo wget "http://2577.asnode.org:43856/supermonASL_fresh_install" -O supermonASL_fresh_install
sudo chmod +x supermonASL_fresh_install
hash
sudo ./supermonASL_fresh_install
echo "Supermon 7.4 installed."

# Install Supermon 7.4 Upgradeable
echo "Installing Upgradeable Supermon 7.4..."
cd /usr/local/sbin
sudo wget "http://2577.asnode.org:43856/supermonASL_latest_update" -O supermonASL_latest_update
sudo chmod +x supermonASL_latest_update
hash
sudo ./supermonASL_latest_update
echo "Upgradeable Supermon 7.4 installed."

# Path to the rpt.conf file
CONF_FILE="/etc/asterisk/rpt.conf"

# Backup the original configuration file
cp $CONF_FILE ${CONF_FILE}.bak

# Add line to rpt.conf
echo "Updating rpt.conf..."
sudo sed -i '/\[functions\]/a SMUPDATE=cmd,/usr/local/sbin/supermonASL_latest_update' /etc/asterisk/rpt.conf
echo "rpt.conf updated."

# Define the cron job and its preceding comment
echo "Setting up cron job..."
CRON_COMMENT="# Supermon 7.4 updater crontab entry"
CRON_JOB="0 3 * * * /var/www/html/supermon/astdb.php cron"

# Add the cron job and comment to the root user's crontab
(sudo crontab -l 2>/dev/null; echo "$CRON_COMMENT"; echo "$CRON_JOB") | sudo crontab -

# Print the current crontab to verify
echo "Current crontab for root:"
sudo crontab -l



echo "All installations and configurations are completed."
