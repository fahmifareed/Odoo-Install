#!/bin/bash

# Script to clone a custom Odoo addons repository and install the addons on Ubuntu VPS

# Set variables
ODOO_HOME="/opt/odoo"  # Replace with the path to your Odoo installation
ODOO_CUSTOM_ADDONS_DIR="/opt/odoo/custom/addons"  # Directory where your custom addons will be located
ODOO_DATABASE="odoo"  # Name of the Odoo database
ODOO_ADMIN_PASSWORD="admin123"  # Replace with your Odoo admin password
ODOO_USER="odoo"  # The system user running the Odoo service
ADDONS_REPO_URL="https://github.com/your-repo/custom-addons.git"  # Replace with your addons repository URL
ADDONS_BRANCH="main"  # Replace with the branch you want to clone

# Check if Odoo service is running
if systemctl is-active --quiet odoo; then
    echo "Odoo service is running."
else
    echo "Odoo service is not running. Please start the Odoo service and try again."
    exit 1
fi

# Clone the custom addons repository
echo "Cloning the custom addons repository..."
if [ -d "$ODOO_CUSTOM_ADDONS_DIR" ]; then
    echo "Custom addons directory already exists. Pulling the latest changes..."
    git -C $ODOO_CUSTOM_ADDONS_DIR pull origin $ADDONS_BRANCH
else
    echo "Custom addons directory does not exist. Cloning the repository..."
    git clone -b $ADDONS_BRANCH $ADDONS_REPO_URL $ODOO_CUSTOM_ADDONS_DIR
fi

if [ $? -ne 0 ]; then
    echo "Failed to clone the repository. Please check the repository URL and branch."
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
