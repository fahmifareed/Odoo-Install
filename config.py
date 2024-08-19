# odoo_installer/config.py

VPS_HOST = "your_vps_ip_or_hostname"
VPS_PORT = 22
VPS_USER = "your_vps_username"
VPS_PASSWORD = "your_vps_password"  # Consider using an SSH key instead of a password for security

ODOO_VERSION = "15.0"
ODOO_PORT = 8069
ODOO_SUPERADMIN = "admin"
ODOO_CONFIG = f"odoo-{ODOO_VERSION}"
ODOO_ADDONS_PATH = "/opt/odoo/custom-addons"
ODOO_DIR = "/opt/odoo/odoo-server"
