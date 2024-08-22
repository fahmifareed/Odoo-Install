#!/bin/bash

# Script to install  Odoo 17  on Ubuntu VPS 

OCB_USER="odoo"
OCB_HOME="/opt/$OCB_USER"
OCB_HOME_EXT="/opt/$OCB_USER/${OCB_USER}-server"
# The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
# Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
# Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OCB_PORT="8069"
# Choose the Odoo version which you want to install. For example: 16.0, 15.0 or 14.0. When using 'master' the master version will be installed.
# IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 14.0
OCB_VERSION="17.0"
# Set this to True if you want to install the Odoo enterprise version!
IS_ENTERPRISE="False"
# Set this to True if you want to install Nginx!
INSTALL_NGINX="True"
# Set the superadmin password - if GENERATE_RANDOM_PASSWORD is set to "True" we will automatically generate a random password, otherwise we use this one
OCB_SUPERADMIN="admin123"
# Set to "True" to generate a random password, "False" to use the variable in OCB_SUPERADMIN
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
# Disable password authentication
#----------------------------------------------------
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config 
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

##
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n============== Update Server ======================="
sudo apt update 
sudo apt upgrade -y
sudo apt autoremove -y


# set the correct timezone on ubuntu
timedatectl set-timezone Africa/Kigali
timedatectl

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
sudo apt install -y postgresql
sudo systemctl start postgresql && sudo systemctl enable postgresql

echo -e "\n=============== Creating the ODOO PostgreSQL User ========================="
sudo su - postgres -c "createuser -s $OCB_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Python Dependencies
#--------------------------------------------------
echo -e "\n=================== Installing Python Dependencies ============================"
sudo apt install -y git python3 python3-dev python3-pip build-essential wget python3-venv python3-wheel python3-cffi libxslt-dev  \
libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi libatlas-base-dev libblas-dev liblcms2-dev \
zlib1g-dev libjpeg8-dev libxrender1

# install libssl
sudo apt -y install libssl-dev

#--------------------------------------------------
# Install Python pip Dependencies
#--------------------------------------------------
echo -e "\n=================== Installing Python pip Dependencies ============================"
sudo apt install -y libpq-dev libxml2-dev libxslt1-dev libffi-dev

echo -e "\n================== Install Wkhtmltopdf ============================================="
sudo apt install -y xfonts-75dpi xfonts-encodings xfonts-utils xfonts-base fontconfig

echo -e "\n================== Install python packages/requirements ============================"
sudo pip3 install --upgrade pip
sudo pip3 install setuptools wheel


echo -e "\n=========== Installing nodeJS NPM and rtlcss for LTR support =================="
sudo curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs npm -y
sudo npm install -g --upgrade npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo npm install -g rtlcss node-gyp

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
echo -e "\n---- Install wkhtmltopdf and place shortcuts on correct place for ODOO 16 ----"
  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb 
  sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
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

#--------------------------------------------------
# Install Odoo from source
#--------------------------------------------------
echo -e "\n========== Installing ODOO Server ==============="
sudo git clone --depth 1 --branch $OCB_VERSION https://www.github.com/OCA/OCB $OCB_HOME_EXT/
sudo pip3 install -r /$OCB_HOME_EXT/requirements.txt
if [ $IS_ENTERPRISE = "True" ]; then
    # Odoo Enterprise install!
    sudo pip3 install psycopg2-binary pdfminer.six
    echo -e "\n============ Create symlink for node ==============="
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo su $OCB_USER -c "mkdir $OCB_HOME/enterprise"
    sudo su $OCB_USER -c "mkdir $OCB_HOME/enterprise/addons"

    GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OCB_VERSION https://www.github.com/odoo/enterprise "$OCB_HOME/enterprise/addons" 2>&1)
    while [[ $GITHUB_RESPONSE == *"Authentication"* ]]; do
        echo "\n============== WARNING ====================="
        echo "Your authentication with Github has failed! Please try again."
        printf "In order to clone and install the Odoo enterprise version you \nneed to be an offical Odoo partner and you need access to\nhttp://github.com/odoo/enterprise.\n"
        echo "TIP: Press ctrl+c to stop this script."
        echo "\n============================================="
        echo " "
        GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OCB_VERSION https://www.github.com/odoo/enterprise "$OCB_HOME/enterprise/addons" 2>&1)
    done

    echo -e "\n========= Added Enterprise code under $OCB_HOME/enterprise/addons ========="
    echo -e "\n============= Installing Enterprise specific libraries ============"
    sudo -H pip3 install num2words ofxparse dbfread ebaysdk firebase_admin pyOpenSSL
    sudo npm install -g less-plugin-clean-css
fi

echo -e "\n========= Create custom module directory ============"
sudo su $OCB_USER -c "mkdir $OCB_HOME/custom"
sudo su $OCB_USER -c "mkdir $OCB_HOME/custom/addons"

echo -e "\n======= Setting permissions on home folder =========="
sudo chown -R $OCB_USER:$OCB_USER $OCB_HOME/

echo -e "\n========== Create server config file ============="
sudo touch /etc/${OCB_CONFIG}.conf

echo -e "\n============= Creating server config file ==========="
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OCB_CONFIG}.conf"
if [ $GENERATE_RANDOM_PASSWORD = "True" ]; then
    echo -e "\n========= Generating random admin password ==========="
    OCB_SUPERADMIN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
fi
sudo su root -c "printf 'admin_passwd = ${OCB_SUPERADMIN}\n' >> /etc/${OCB_CONFIG}.conf"
if [ $OCB_VERSION > "11.0" ];then
    sudo su root -c "printf 'http_port = ${OCB_PORT}\n' >> /etc/${OCB_CONFIG}.conf"
else
    sudo su root -c "printf 'xmlrpc_port = ${OCB_PORT}\n' >> /etc/${OCB_CONFIG}.conf"
fi
sudo su root -c "printf 'logfile = /var/log/${OCB_USER}/${OCB_CONFIG}.log\n' >> /etc/${OCB_CONFIG}.conf"

if [ $IS_ENTERPRISE = "True" ]; then
    sudo su root -c "printf 'addons_path=${OCB_HOME}/enterprise/addons,${OCB_HOME_EXT}/addons\n' >> /etc/${OCB_CONFIG}.conf"
else
    sudo su root -c "printf 'addons_path=${OCB_HOME_EXT}/addons,${OCB_HOME}/custom/addons\n' >> /etc/${OCB_CONFIG}.conf"
fi

# echo -e "\n======== Adding Enterprise or custom modules ============="
if [ $IS_ENTERPRISE = "True" ]; then
  
  echo -e "\n======== Adding some enterprise modules ============="
  wget https://www.soladrive.com/downloads/enterprise-15.0.tar.gz
  tar -zxvf enterprise-15.0.tar.gz
  cp -rf odoo-15.0*/odoo/addons/* ${OCB_HOME}/enterprise/addons
  rm enterprise-15.0.tar.gz
  chown -R $OCB_USER:$OCB_USER ${OCB_HOME}/
fi

sudo chown $OCB_USER:$OCB_USER /etc/${OCB_CONFIG}.conf
sudo chmod 640 /etc/${OCB_CONFIG}.conf

#--------------------------------------------------
# Adding Odoo as a deamon (Systemd)
#--------------------------------------------------

echo -e "\n========== Create Odoo systemd file ==============="
cat <<EOF > /lib/systemd/system/$OCB_USER.service

[Unit]
Description=Odoo Open Source ERP and CRM
After=network.target

[Service]
Type=simple
User=$OCB_USER
Group=$OCB_USER
ExecStart=$OCB_HOME_EXT/odoo-bin --config /etc/${OCB_CONFIG}.conf  --logfile /var/log/${OCB_USER}/${OCB_CONFIG}.log
KillMode=mixed

[Install]
WantedBy=multi-user.target

EOF

sudo chmod 755 /lib/systemd/system/$OCB_USER.service
sudo chown root: /lib/systemd/system/$OCB_USER.service

echo -e "\n======== Odoo startup File ============="
sudo systemctl daemon-reload
sudo systemctl enable --now $OCB_USER.service
sudo systemctl start $OCB_USER.service

sudo systemctl restart $OCB_USER.service

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
   client_max_body_size 500M;

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
  gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
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
if [ $INSTALL_NGINX = "True" ] && [ $ENABLE_SSL = "True" ]  && [ $WEBSITE_NAME != "example.com" ];then
  sudo apt-get remove certbot
  sudo snap install core
  sudo snap refresh core
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  sudo certbot --nginx -d $WEBSITE_NAME 
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
sudo ufw allow 8069/tcp
sudo ufw allow 8072/tcp
sudo ufw enable 

echo -e "\n================== Status of Odoo Service ============================="
sudo systemctl status $OCB_USER
echo "\n========================================================================="
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OCB_PORT"
echo "User service: $OCB_USER"
echo "User PostgreSQL: $OCB_USER"
echo "Code location: $OCB_USER"
echo "Addons folder: $OCB_USER/$OCB_CONFIG/addons/"
echo "Password superadmin (database): $OCB_SUPERADMIN"
echo "Start Odoo service: sudo systemctl start $OCB_USER"
echo "Stop Odoo service: sudo systemctl stop $OCB_USER"
echo "Restart Odoo service: sudo systemctl restart $OCB_USER"
if [ $INSTALL_NGINX = "True" ]; then
  echo "Nginx configuration file: /etc/nginx/sites-available/$OCB_USER"
fi
echo -e "\n========================================================================="
