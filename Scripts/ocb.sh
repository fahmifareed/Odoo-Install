#!/bin/bash

# Script to install OCB (Odoo Community Backports) on Ubuntu VPS

# Variables
OCB_VERSION="14.0"  # Set your desired OCB version here (e.g., 14.0, 15.0)
OCB_HOME="/opt/ocb"  # Directory where OCB will be installed
OCB_USER="odoo"  # The system user to run the OCB service
OCB_CONF="/etc/ocb.conf"  # OCB configuration file path
OCB_CUSTOM_ADDONS_DIR="$OCB_HOME/custom_addons"  # Directory for custom addons
POSTGRES_VERSION="12"  # PostgreSQL version
OCB_ADMIN_PASSWORD="admin"  # Odoo admin password
OCB_DATABASE="ocb_db"  # The name of the Odoo database


OCB_USER="odoo"
OCB_HOME="/opt/ocb"
OCB_HOME_EXT="/opt/ocb/ocb-server"
# The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
# Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
# Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OCB_PORT="8069"
# Choose the Odoo version which you want to install. For example: 14.0, 13.0 or 12.0. When using 'master' the master version will be installed.
# IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 14.0
OCB_VERSION="14.0"
# Set this to True if you want to install the Odoo enterprise version!
IS_ENTERPRISE="False"
# Set this to True if you want to install Nginx!
INSTALL_NGINX="True"
# Set the superadmin password - if GENERATE_RANDOM_PASSWORD is set to "True" we will automatically generate a random password, otherwise we use this one
OCB_SUPERADMIN="admin"
# Set to "True" to generate a random password, "False" to use the variable in OE_SUPERADMIN
GENERATE_RANDOM_PASSWORD="False"
OCB_CONFIG="${OCB_USER}-server"
# Set the website name
WEBSITE_NAME="fahmi.xyz"
# Set the default Odoo longpolling port (you still have to use -c /etc/odoo-server.conf for example to use this.)
LONGPOLLING_PORT="8072"
# Set to "True" to install certbot and have ssl enabled, "False" to use http
ENABLE_SSL="True"
# Provide Email to register ssl certificate
ADMIN_EMAIL="info@fahmi.xyz"

###
#----------------------------------------------------
# Uncomment if you want to disable password authentication
#----------------------------------------------------
# sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
# sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config 
# sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# sudo systemctl restart sshd

##
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n============== Update Server ======================="
# universe package is for Ubuntu 20.x
sudo apt install -y software-properties-common
sudo add-apt-repository universe

# libpng12-0 dependency for wkhtmltopdf
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ focal main"

sudo apt update 
sudo apt upgrade -y
sudo apt autoremove -y

#--------------------------------------------------
# Set up the timezones
#--------------------------------------------------
# set the correct timezone on ubuntu
timedatectl set-timezone Africa/Kigali
timedatectl

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n================ Install PostgreSQL Server =========================="
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql
sudo systemctl start postgresql && sudo systemctl enable postgresql

echo -e "\n=============== Creating the ODOO PostgreSQL User ========================="
sudo su - postgres -c "createuser -s $OCB_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Python Dependencies
#--------------------------------------------------
echo -e "\n=================== Installing Python Dependencies ============================"
sudo apt install -y git python3-dev python3-pip build-essential wget python3-venv python3-wheel python3-cffi libxslt-dev \
libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi libssl-dev

#--------------------------------------------------
# Install Python pip Dependencies
#--------------------------------------------------
echo -e "\n=================== Installing Python pip Dependencies ============================"
sudo apt install -y libpq-dev libxml2-dev libxslt1-dev libffi-dev

echo -e "\n================== Install Wkhtmltopdf ============================================="
sudo apt install -y xfonts-75dpi xfonts-encodings xfonts-utils xfonts-base fontconfig

sudo apt install -y libfreetype6-dev zlib1g-dev libblas-dev libatlas-base-dev libtiff5-dev libjpeg8-dev \
libopenjp2-7-dev liblcms2-dev liblcms2-utils libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev

sudo add-apt-repository ppa:linuxuprising/libpng12
sudo apt update
sudo apt install -y libpng12-0

echo -e "\n================== Install python packages/requirements ============================"
wget https://raw.githubusercontent.com/odoo/odoo/${OCB_VERSION}/requirements.txt
sudo pip3 install --upgrade pip
sudo pip3 install setuptools wheel
sudo pip3 install -r requirements.txt

echo -e "\n=========== Installing nodeJS NPM and rtlcss for LTR support =================="
sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs -y
sudo npm install -g --upgrade npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less-plugin-clean-css
sudo npm install -g rtlcss node-gyp

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
echo -e "\n---- Install wkhtmltopdf and place shortcuts on correct place for ODOO 15 ----"
###  WKHTMLTOPDF download links
## === Ubuntu Focal x64 === (for other distributions please replace this link,
## in order to have correct version of wkhtmltopdf installed, for a danger note refer to
## https://github.com/odoo/odoo/wiki/Wkhtmltopdf ):
## https://www.odoo.com/documentation/15.0/setup/install.html#debian-ubuntu

  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb
  sudo dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
   else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
  fi
  
echo -e "\n============== Create ODOO system user ========================"
sudo adduser --system --quiet --shell=/bin/bash --home=$OCB_HOME --gecos 'ODOO' --group $OCB_USER

#The user should also be added to the sudo'ers group.
sudo adduser $OCB_USER sudo

echo -e "\n=========== Create Log directory ================"
sudo mkdir /var/log/$OCB_USER
sudo chown -R $OCB_USER:$OCB_USER /var/log/$OCB_USER

# Install OCB
echo "Cloning OCB repository..."
sudo mkdir -p $OCB_HOME
sudo git clone https://github.com/OCA/OCB.git -b $OCB_VERSION $OCB_HOME
sudo chown -R $OCB_USER:$OCB_USER $OCB_HOME

# Install Python dependencies
echo "Installing Python dependencies..."
sudo pip3 install -r $OCB_HOME/requirements.txt

# Manually install critical packages to avoid missing dependencies
echo "Installing PyPDF2..."
sudo pip3 install PyPDF2

echo -e "\n========= Create custom module directory ============"
sudo su $OCB_USER -c "mkdir $OCB_HOME/custom"
sudo su $OCB_USER -c "mkdir $OCB_HOME/custom/addons"

echo -e "\n======= Setting permissions on home folder =========="
sudo chown -R $OCB_USER:$OCB_USER $OCB_HOME/


# Configure OCB
echo "Configuring OCB..."
sudo cp $OCB_HOME/debian/odoo.conf $OCB_CONF
sudo chown $OCB_USER:$OCB_USER $OCB_CONF
sudo chmod 640 $OCB_CONF

# Update configuration file
sudo bash -c "cat > $OCB_CONF <<EOF
[options]
addons_path = $OCB_HOME/addons,$OCB_CUSTOM_ADDONS_DIR
admin_passwd = $OCB_ADMIN_PASSWORD
db_host = False
db_port = False
db_user = $OCB_USER
db_password = False
logfile = /var/log/ocb/ocb.log
EOF"

# Set up log directory
echo "Setting up log directory..."
sudo mkdir -p /var/log/ocb
sudo chown $OCB_USER:$OCB_USER /var/log/ocb

#--------------------------------------------------
# Install Nginx if needed
#--------------------------------------------------
echo -e "\n======== Installing nginx ============="
if [ $INSTALL_NGINX = "True" ]; then
  echo -e "\n---- Installing and setting up Nginx ----"
  sudo apt install -y nginx
  sudo systemctl enable nginx
  
cat <<EOF > /etc/nginx/sites-available/$OCB_USER

# odoo server
upstream $OCB_USER {
 server 127.0.0.1:$OCB_PORT;
}

upstream ${OCB_USER}chat {
 server 127.0.0.1:$LONGPOLLING_PORT;
}

server {
    listen 80;
    server_name $WEBSITE_NAME;

   # Specifies the maximum accepted body size of a client request,
   # as indicated by the request header Content-Length.
   client_max_body_size 0;

   # log
   access_log /var/log/nginx/$OCB_USER-access.log;
   error_log /var/log/nginx/$OCB_USER-error.log;

   # add ssl specific settings
   keepalive_timeout 90;

   # increase proxy buffer to handle some Odoo web requests
   proxy_buffers 16 64k;
   proxy_buffer_size 128k;

   proxy_read_timeout 720s;
   proxy_connect_timeout 720s;
   proxy_send_timeout 720s;
  
   # Add Headers for odoo proxy mode
   proxy_set_header Host \$host;
   proxy_set_header X-Forwarded-Host \$host;
   proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
   proxy_set_header X-Forwarded-Proto \$scheme;
   proxy_set_header X-Real-IP \$remote_addr;

   # Redirect requests to odoo backend server
   location / {
     proxy_redirect off;
     proxy_pass http://$OCB_USER;
   }

   # Redirect longpoll requests to odoo longpolling port
   location /longpolling {
       proxy_pass http://${OCB_USER}chat;
   }

   # cache some static data in memory for 90mins
   # under heavy load this should relieve stress on the Odoo web interface a bit.
   location ~* /web/static/ {
       proxy_cache_valid 200 90m;
       proxy_buffering on;
       expires 864000;
       proxy_pass http://$OCB_USER;
  }

  # common gzip
    gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;
    gzip on;
}
 
EOF

  sudo mv ~/odoo /etc/nginx/sites-available/
  sudo ln -s /etc/nginx/sites-available/$OCB_USER /etc/nginx/sites-enabled/$OCB_USER
  sudo rm /etc/nginx/sites-enabled/default
  sudo rm /etc/nginx/sites-available/default
  
  sudo systemctl reload nginx
  sudo su root -c "printf 'proxy_mode = True\n' >> /etc/${OCB_CONFIG}.conf"
  echo "Done! The Nginx server is up and running. Configuration can be found at /etc/nginx/sites-available/$OCB_USER"
else
  echo "\n===== Nginx isn't installed due to choice of the user! ========"
fi

#--------------------------------------------------
# Enable ssl with certbot
#--------------------------------------------------
if [ $INSTALL_NGINX = "True" ] && [ $ENABLE_SSL = "True" ] && [ $ADMIN_EMAIL != "odoo@example.com" ]  && [ $WEBSITE_NAME != "example.com" ];then
  sudo apt-get remove certbot
  sudo snap install core
  sudo snap refresh core
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  sudo certbot --nginx -d $WEBSITE_NAME --noninteractive --agree-tos --email $ADMIN_EMAIL --redirect
  sudo systemctl reload nginx  
  echo "\n============ SSL/HTTPS is enabled! ========================"
else
  echo "\n==== SSL/HTTPS isn't enabled due to choice of the user or because of a misconfiguration! ======"
fi

#--------------------------------------------------
# UFW Firewall
#--------------------------------------------------
sudo apt install -y ufw 

sudo ufw allow 'Nginx Full'
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw allow 22/tcp
sudo ufw allow 6010/tcp
#sudo ufw allow 5432//tcp
sudo ufw allow 8069/tcp
sudo ufw allow 8072/tcp
sudo ufw enable 

# Set up systemd service
echo "Creating systemd service for OCB..."
sudo bash -c "cat > /etc/systemd/system/ocb.service <<EOF
[Unit]
Description=OCB (Odoo Community Backports)
Documentation=https://www.odoo.com/documentation/user/
[Service]
Type=simple
User=$OCB_USER
ExecStart=$OCB_HOME/odoo-bin -c $OCB_CONF
[Install]
WantedBy=multi-user.target
EOF"

# Start OCB service
echo "Starting OCB service..."
sudo systemctl daemon-reload
sudo systemctl start ocb
sudo systemctl enable ocb

# Create OCB database
echo "Creating OCB database..."
sudo -u $OCB_USER $OCB_HOME/odoo-bin -d $OCB_DATABASE --init=base --stop-after-init

echo "OCB installation complete. Access your OCB instance at http://localhost:8069"
