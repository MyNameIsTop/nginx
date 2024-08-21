#!/bin/bash

# Update package lists and install prerequisites
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev

# Add the NGINX signing key
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo tee /etc/apt/trusted.gpg.d/nginx.asc

# Set up the APT repository for NGINX stable
echo "deb http://nginx.org/packages/ubuntu/ `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# Install NGINX
sudo apt-get update
sudo apt-get install -y nginx

# Stop NGINX to perform configuration changes
sudo systemctl stop nginx

# Download and apply custom configuration based on cocsirt-config-guide
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/inetspa/cocsirt-config-guide/main/WebServer/nginx.conf

# Adjust permissions if necessary
sudo chown root:root /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/nginx.conf

# Prompt for the number of worker nodes
read -p "Enter the number of worker nodes: " NUM_NODES

# Initialize upstream configuration
UPSTREAM_CONF="upstream backend {"

# Loop through to get each worker node's IP address
for (( i=1; i<=NUM_NODES; i++ ))
do
    read -p "Enter the IP address of worker node $i: " WORKER_IP
    UPSTREAM_CONF+="\n    server ${WORKER_IP}:30080;"
    UPSTREAM_CONF+="\n    server ${WORKER_IP}:30443;"
done

UPSTREAM_CONF+="\n}"

# Append upstream configuration to nginx.conf
echo -e "$UPSTREAM_CONF" | sudo tee -a /etc/nginx/nginx.conf

# Function to add a new virtual host
add_vhost() {
    read -p "Enter the server name (domain name) for this virtual host: " SERVER_NAME
    read -p "Enter the root directory for this virtual host (e.g., /var/www/html): " ROOT_DIR

    VHOST_CONF="
server {
    listen 80;
    server_name ${SERVER_NAME};

    root ${ROOT_DIR};
    index index.html index.htm;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}"

    # Create a new vhost configuration file
    echo "$VHOST_CONF" | sudo tee /etc/nginx/conf.d/${SERVER_NAME}.conf

    echo "Virtual host for ${SERVER_NAME} has been added."
}

# Prompt to add the first virtual host with SSL
echo "Configuring the first virtual host with SSL..."
read -p "Enter the server name (domain name) for this virtual host: " SERVER_NAME
read -p "Enter the root directory for this virtual host (e.g., /var/www/html): " ROOT_DIR

VHOST_SSL_CONF="
server {
    listen 443 ssl;
    server_name ${SERVER_NAME};

    ssl_certificate /etc/nginx/ssl/domain.crt;
    ssl_certificate_key /etc/nginx/ssl/domain.key;

    root ${ROOT_DIR};
    index index.html index.htm;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}"

# Create the SSL vhost configuration file
echo "$VHOST_SSL_CONF" | sudo tee /etc/nginx/conf.d/${SERVER_NAME}_ssl.conf

echo "SSL Virtual host for ${SERVER_NAME} has been added."

# Prompt to add additional virtual hosts without SSL
while true; do
    read -p "Would you like to add another virtual host? (y/n): " ADD_MORE
    case $ADD_MORE in
        [Yy]* ) add_vhost;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Restart NGINX to apply changes
sudo systemctl start nginx

# Check the status of NGINX
sudo systemctl status nginx

echo "NGINX 1.26 installation and configuration on Ubuntu 22.04 is complete."
