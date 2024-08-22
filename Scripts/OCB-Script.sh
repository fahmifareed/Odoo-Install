# Script to install OCB (Odoo Community Backports) on Ubuntu VPS

# Variables
OCB_VERSION="14.0"  # Set your desired OCB version here (e.g., 14.0, 15.0)
OCB_HOME="/opt/ocb"  # Directory where OCB will be installed
OCB_USER="odoo"  # The system user to run the OCB service
OCB_CONF="/etc/ocb.conf"  # OCB configuration file path
OCB_CUSTOM_ADDONS_DIR="$OCB_HOME/custom_addons"  # Directory for custom addons
POSTGRES_VERSION="12"  # PostgreSQL version
OCB_ADMIN_PASSWORD="admin123"  # Odoo admin password
OCB_DATABASE="ocb_db"  # The name of the Odoo database


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

#--------------------------------------------------
# Set up the timezones
#--------------------------------------------------
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
###  WKHTMLTOPDF download links
## === Ubuntu Jammy x64 === (for other distributions please replace this link,
## in order to have correct version of wkhtmltopdf installed, for a danger note refer to
## https://github.com/odoo/odoo/wiki/Wkhtmltopdf ):
## https://www.odoo.com/documentation/16.0/setup/install.html#debian-ubuntu

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

# Install OCB
echo "\n=========== Cloning OCB repository... ================"
sudo mkdir -p $OCB_HOME
sudo git clone https://github.com/OCA/OCB.git -b $OCB_VERSION $OCB_HOME
sudo chown -R $OCB_USER:$OCB_USER $OCB_HOME
