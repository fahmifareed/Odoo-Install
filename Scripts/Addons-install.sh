#!/bin/bash

# Script to install custom Odoo addons on Ubuntu VPS

# Set variables
ODOO_HOME="/opt/odoo"  # Replace with the path to your Odoo installation
ODOO_CUSTOM_ADDONS_DIR="/opt/odoo/custom_addons"  # Directory where your custom addons are located
ODOO_DATABASE="odoo"  # Name of the Odoo database
ODOO_ADMIN_PASSWORD="admin123"  # Replace with your Odoo admin password
ODOO_USER="odoo"  # The system user running the Odoo service

# Check if Odoo service is running
if systemctl is-active --quiet odoo; then
    echo "Odoo service is running."
else
    echo "Odoo service is not running. Please start the Odoo service and try again."
    exit 1
fi

# Install custom addons
echo "Installing custom addons..."

for addon in $ODOO_CUSTOM_ADDONS_DIR/*; do
    if [ -d "$addon" ]; then
        addon_name=$(basename "$addon")
        echo "Installing addon: $addon_name"

        sudo -u $ODOO_USER $ODOO_HOME/odoo-bin -d $ODOO_DATABASE --addons-path=$ODOO_CUSTOM_ADDONS_DIR -i $addon_name --stop-after-init --log-level=debug
        if [ $? -eq 0 ]; then
            echo "Addon $addon_name installed successfully."
        else
            echo "Failed to install addon $addon_name."
            exit 1
        fi
    fi
done

echo "All custom addons have been installed."
