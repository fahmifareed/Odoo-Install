# Odoo Installation Guide
 ![GitHub repo size](https://img.shields.io/github/repo-size/fahmifareed/Odoo-Install) ![GitHub contributors](https://img.shields.io/github/contributors/fahmifareed/Odoo-Install) ![GitHub last commit](https://img.shields.io/github/last-commit/fahmifareed/Odoo-Install) ![License](https://img.shields.io/github/license/fahmifareed/Odoo-Install)

Welcome to the Odoo Installation repository. This guide provides detailed instructions for installing Odoo on various environments, ensuring a smooth setup for developers and system administrators.

## Table of Contents

- [Introduction](#introduction) ![Introduction](https://img.icons8.com/ios-filled/16/000000/info.png)
- [Prerequisites](#prerequisites) ![Prerequisites](https://img.icons8.com/ios-filled/16/000000/checklist.png)
- [Installation](#installation) ![Installation](https://img.icons8.com/ios-filled/16/000000/installing-updates.png)
  - [Step 1: System Update](#step-1-system-update) ![Step 1](https://img.icons8.com/ios-filled/16/000000/refresh.png)
  - [Step 2: Install Dependencies](#step-2-install-dependencies) ![Step 2](https://img.icons8.com/ios-filled/16/000000/module.png)
  - [Step 3: Install PostgreSQL](#step-3-install-postgresql) ![Step 3](https://img.icons8.com/ios-filled/16/000000/database.png)
  - [Step 4: Install Odoo](#step-4-install-odoo) ![Step 4](https://img.icons8.com/ios-filled/16/000000/download-from-cloud.png)
  - [Step 5: Configure Odoo](#step-5-configure-odoo) ![Step 5](https://img.icons8.com/ios-filled/16/000000/settings.png)
  - [Step 6: Run Odoo](#step-6-run-odoo) ![Step 6](https://img.icons8.com/ios-filled/16/000000/run-command.png)
- [Configuration Parameters](#configuration-parameters) ![Parameters](https://img.icons8.com/ios-filled/16/000000/settings.png)
- [Advanced Configuration](#advanced-configuration) ![Advanced Configuration](https://img.icons8.com/ios-filled/16/000000/engineering.png)
  - [Nginx as a Reverse Proxy](#nginx-as-a-reverse-proxy) ![Nginx](https://img.icons8.com/color/16/000000/nginx.png)
  - [SSL Configuration](#ssl-configuration) ![SSL](https://img.icons8.com/color/16/lock.png)
  - [Automatic Backups](#automatic-backups) ![Backups](https://img.icons8.com/ios-filled/16/cloud-backup-restore.png)
- [Common Issues and Troubleshooting](#common-issues-and-troubleshooting) ![Troubleshooting](https://img.icons8.com/ios-filled/16/000000/bug.png)
- [Contributing](#contributing) ![Contributing](https://img.icons8.com/ios-filled/16/000000/conference-call.png)
- [License](#license) ![License](https://img.icons8.com/ios-filled/16/certificate.png)
- [Contact](#contact) ![Contact](https://img.icons8.com/ios-filled/16/000000/phone.png)


## Introduction ![Introduction](https://img.icons8.com/ios-filled/32/000000/info.png)

This repository contains scripts and instructions for installing Odoo on a Linux-based server. Odoo is a comprehensive suite of business applications including CRM, e-Commerce, accounting, inventory, point of sale, project management, and more. This guide is intended to simplify the setup process, providing clear and concise steps to get your Odoo instance up and running.

## Prerequisites ![Prerequisites](https://img.icons8.com/ios-filled/32/000000/checklist.png)

Before you begin the installation, ensure that your server meets the following requirements:

- **Operating System**: Ubuntu 20.04 LTS or later (Recommended) or other Linux distributions.
- **Processor**: Dual-core processor or better.
- **RAM**: Minimum 2 GB (4 GB or more recommended for production).
- **Disk Space**: Minimum 20 GB of free space.
- **Python Version**: Python 3.6 or higher.
- **PostgreSQL**: Version 10 or higher.

Ensure you have `sudo` privileges on the server.

## Installation ![Installation](https://img.icons8.com/ios-filled/32/000000/installing-updates.png)

### Step 1: System Update ![System Update](https://img.icons8.com/ios-filled/32/000000/refresh.png)

Before starting the installation, update your system to the latest packages:

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### Step 2: Install Dependencies ![Dependencies](https://img.icons8.com/ios-filled/32/000000/module.png)

Install the required dependencies for Odoo:

```bash
sudo apt-get install -y git python3-pip build-essential wget
sudo apt-get install -y python3-dev python3-venv libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev libssl-dev libjpeg-dev libpq-dev
```

### Step 3: Install PostgreSQL ![PostgreSQL](https://img.icons8.com/ios-filled/32/000000/database.png)

Odoo uses PostgreSQL as its database backend. Install it using:

```bash
sudo apt-get install -y postgresql postgresql-server-dev-all
```

Once installed, create a PostgreSQL user for Odoo:

```bash
sudo su - postgres
createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo
exit
```

### Step 4: Install Odoo ![Install Odoo](https://img.icons8.com/ios-filled/32/download-from-cloud.png)


Clone the Odoo source code from the official repository:

```bash
git clone https://www.github.com/odoo/odoo --depth 1 --branch 14.0 --single-branch odoo
```

Create a Python virtual environment and install Odoo dependencies:

```bash
cd odoo
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 5: Configure Odoo ![Configure Odoo](https://img.icons8.com/ios-filled/32/000000/settings.png)

Copy the sample configuration file and adjust it to your environment:

```bash
cp odoo/debian/odoo.conf /etc/odoo.conf
nano /etc/odoo.conf
```

Edit the configuration file to match your setup, particularly the database settings.

### Step 6: Run Odoo ![Run Odoo](https://img.icons8.com/ios-filled/32/000000/run-command.png)

Start the Odoo server using the following command:

```bash
./odoo/odoo-bin -c /etc/odoo.conf
```

You should now be able to access Odoo at `http://your-server-ip:8069`.

## Configuration Parameters ![Parameters](https://img.icons8.com/ios-filled/32/000000/settings.png)

Before running the installation script, you can modify several parameters to customize the setup according to your needs. Below is a list of the most commonly used parameters:

- **`OE_USER`**: This parameter specifies the username for the system user that will be created for running Odoo. You can set this to any preferred username.

- **`GENERATE_RANDOM_PASSWORD`**: If set to `True`, the script will generate a random and secure password for the Odoo admin user. If set to `False`, the password will be set to the value configured in `OE_SUPERADMIN`. The default value is `True`.

- **`OE_PORT`**: This parameter defines the port on which Odoo will run. The default Odoo port is `8069`, but you can set it to any available port on your server.

- **`OE_VERSION`**: Specifies the version of Odoo to be installed. For example, set this to `14.0` for installing Odoo version 14.

- **`IS_ENTERPRISE`**: Set this to `True` to install the Odoo Enterprise version on top of version `16.0`. If you want to install the community version of Odoo 16, set this to `False`.

- **`OE_SUPERADMIN`**: This is the master password for the Odoo installation. It is crucial to set this parameter to a secure password if `GENERATE_RANDOM_PASSWORD` is set to `False`.

- **`INSTALL_NGINX`**: This parameter is set to `True` by default, meaning that Nginx will be installed and configured as a reverse proxy for Odoo. Set it to `False` if you do not want to install Nginx.

- **`

WEBSITE_NAME`**: If you are installing Nginx, set this parameter to define the website name used in the Nginx configuration.

- **`ENABLE_SSL`**: Set this parameter to `True` if you wish to install [certbot](https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx) and configure Nginx to use HTTPS with a free Let's Encrypt SSL certificate.

- **`ADMIN_EMAIL`**: This is required for Let's Encrypt registration when `ENABLE_SSL` is set to `True`. Replace the default placeholder with your organization's email address.

### Important Notes
- Both `INSTALL_NGINX` and `ENABLE_SSL` must be set to `True` and `ADMIN_EMAIL` must be replaced with a valid email address to enable SSL through Let's Encrypt.
  
  _By enabling SSL through Let's Encrypt, you agree to the following [policies](https://www.eff.org/code/privacy/policy)._ 

Make sure to modify these parameters in the script before running the installation to fit your specific setup requirements.

## Advanced Configuration ![Advanced Configuration](https://img.icons8.com/ios-filled/32/000000/engineering.png)

### Nginx as a Reverse Proxy ![Nginx](https://img.icons8.com/color/32/000000/nginx.png)

To serve Odoo over the default HTTP/HTTPS ports, set up Nginx as a reverse proxy:

```bash
sudo apt-get install nginx
```

Configure Nginx to forward requests to Odoo:

```bash
sudo nano /etc/nginx/sites-available/odoo
```

Add the necessary server configuration and then enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### SSL Configuration ![SSL](https://img.icons8.com/color/32/lock.png)

For secure HTTPS access, you can use Let's Encrypt:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### Automatic Backups ![Backups](https://img.icons8.com/ios-filled/32/cloud-backup-restore.png)

Set up automatic backups to ensure data safety:

```bash
sudo nano /etc/cron.daily/odoo_backup
```

Add a script to perform daily backups and make it executable:

```bash
sudo chmod +x /etc/cron.daily/odoo_backup
```

## Common Issues and Troubleshooting ![Troubleshooting](https://img.icons8.com/ios-filled/32/000000/bug.png)

If you encounter issues during installation or running Odoo, please refer to the [Odoo documentation](https://www.odoo.com/documentation/) or visit the [Odoo community forums](https://www.odoo.com/forum/help-1).

## Contributing ![Contributing](https://img.icons8.com/ios-filled/32/000000/conference-call.png)

Contributions to this repository are welcome. Please fork the repository, create a feature branch, and submit a pull request for review.

## License ![License](https://img.icons8.com/ios-filled/32/certificate.png)

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact ![Contact](https://img.icons8.com/ios-filled/32/000000/phone.png)



Feel free to reach out to me via the following platforms:

[![LinkedIn](https://img.icons8.com/ios-filled/20/0077B5/linkedin.png)](https://www.linkedin.com/in/fahmifareed) 
[![Twitter](https://img.icons8.com/ios-filled/20/1DA1F2/twitter.png)](https://twitter.com/fvhmifvreed) 
[![Email](https://img.icons8.com/ios-filled/20/000000/email.png)](mailto:info@fahmi.xyz)



