How to Use:
Save this script as install_nginx_with_ssl_vhost.sh.
Make it executable: chmod +x install_nginx_with_ssl_vhost.sh.
Run it with sudo ./install_nginx_with_ssl_vhost.sh.
What This Script Does:
Installs NGINX 1.26 on Ubuntu 22.04 based on the configuration from the cocsirt-config-guide.
Prompts for the number of worker nodes and their IP addresses, configuring upstream servers on ports 30080 and 30443 for an ingress controller.
Configures the first virtual host with SSL, using certificates located at /etc/nginx/ssl/domain.crt and /etc/nginx/ssl/domain.key.
Asks if you want to add more virtual hosts without SSL.
Creates individual configuration files for each virtual host in the /etc/nginx/conf.d/ directory.
Restarts NGINX to apply the configuration changes.
This script ensures that your first virtual host is secured with SSL, while allowing for additional non-SSL virtual hosts as needed.






