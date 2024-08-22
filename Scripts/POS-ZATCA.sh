#!/bin/bash

# Script to install POS and ZATCA modules in Odoo on Ubuntu VPS

# Set variables
ODOO_HOME="/opt/odoo"  # Path to your existing Odoo installation
ODOO_CUSTOM_ADDONS_DIR="$ODOO_HOME/custom_addons"  # Directory for custom addons
ODOO_DATABASE="odoo_pos_db"  # The name of the Odoo database
ODOO_USER="odoo"  # The system user running the Odoo service
POS_REPO_URL="https://github.com/your-repo/pos-module.git"  # Replace with your POS custom module repo URL
ZATCA_REPO_URL="https://github.com/your-repo/zatca-module.git"  # Replace with your ZATCA custom module repo URL

# Ensure custom addons directory exists
sudo mkdir -p $ODOO_CUSTOM_ADDONS_DIR

# Clone POS and ZATCA modules
echo "Cloning POS and ZATCA modules..."
sudo git clone $POS_REPO_URL $ODOO_CUSTOM_ADDONS_DIR/pos_module
sudo git clone $ZATCA_REPO_URL $ODOO_CUSTOM_ADDONS_DIR/zatca_module

# Set permissions
sudo chown -R $ODOO_USER:$ODOO_USER $ODOO_CUSTOM_ADDONS_DIR

# Install POS and ZATCA modules in Odoo
echo "Installing POS and ZATCA modules..."
sudo -u $ODOO_USER $ODOO_HOME/odoo-bin -d $ODOO_DATABASE --addons-path=$ODOO_HOME/addons,$ODOO_CUSTOM_ADDONS_DIR -i point_of_sale,pos_module,zatca_module --stop-after-init --log-level=info

echo "POS and ZATCA modules have been installed successfully."
