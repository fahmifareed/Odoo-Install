# odoo_installer/odoo_installer.py

import paramiko
import os
import subprocess
import sys
from .config import (
    VPS_HOST,
    VPS_PORT,
    VPS_USER,
    VPS_PASSWORD,
    ODOO_VERSION,
    ODOO_PORT,
    ODOO_SUPERADMIN,
    ODOO_CONFIG,
    ODOO_ADDONS_PATH,
    ODOO_DIR
)

# Commands for Odoo installation
INSTALL_COMMANDS = f"""
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install python3-pip build-essential wget git python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less gdebi-core libjpeg-dev zlib1g-dev libpq-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libx11-dev libblas-dev liblapack-dev libatlas-base-dev -y
sudo apt-get install postgresql postgresql-server-dev-all -y
sudo su - postgres -c "createuser -s $USER"
sudo apt-get install xfonts-75dpi xfonts-base -y
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
sudo adduser --system --home=/opt/odoo --group odoo
sudo mkdir /var/log/odoo
sudo chown odoo: /var/log/odoo
sudo git clone --depth 1 --branch {ODOO_VERSION} https://www.github.com/odoo/odoo {ODOO_DIR}/
sudo apt-get install python3-venv -y
python3 -m venv {ODOO_DIR}/venv
source {ODOO_DIR}/venv/bin/activate
pip3 install wheel
pip3 install -r {ODOO_DIR}/requirements.txt
deactivate
sudo mkdir {ODOO_ADDONS_PATH}
sudo chown odoo: {ODOO_ADDONS_PATH}
sudo cp {ODOO_DIR}/debian/odoo.conf /etc/{ODOO_CONFIG}.conf
sudo chown odoo: /etc/{ODOO_CONFIG}.conf
sudo chmod 640 /etc/{ODOO_CONFIG}.conf
echo "[options]" >> /etc/{ODOO_CONFIG}.conf
echo "; This is the password that allows database operations:" >> /etc/{ODOO_CONFIG}.conf
echo "admin_passwd = {ODOO_SUPERADMIN}" >> /etc/{ODOO_CONFIG}.conf
echo "db_host = False" >> /etc/{ODOO_CONFIG}.conf
echo "db_port = False" >> /etc/{ODOO_CONFIG}.conf
echo "db_user = odoo" >> /etc/{ODOO_CONFIG}.conf
echo "db_password = False" >> /etc/{ODOO_CONFIG}.conf
echo "addons_path = {ODOO_DIR}/addons,{ODOO_ADDONS_PATH}" >> /etc/{ODOO_CONFIG}.conf
echo "logfile = /var/log/odoo/{ODOO_CONFIG}.log" >> /etc/{ODOO_CONFIG}.conf
echo "xmlrpc_port = {ODOO_PORT}" >> /etc/{ODOO_CONFIG}.conf
echo "[Unit]" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "Description=Odoo" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "Documentation=http://www.odoo.com" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "After=network.target" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "[Service]" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "Type=simple" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "User=odoo" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "ExecStart={ODOO_DIR}/venv/bin/python3 {ODOO_DIR}/odoo-bin -c /etc/{ODOO_CONFIG}.conf" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "[Install]" >> /etc/systemd/system/{ODOO_CONFIG}.service
echo "WantedBy=default.target" >> /etc/systemd/system/{ODOO_CONFIG}.service
sudo systemctl daemon-reload
sudo systemctl enable {ODOO_CONFIG}.service
sudo systemctl start {ODOO_CONFIG}.service
"""

# (Rest of the script remains the same)
