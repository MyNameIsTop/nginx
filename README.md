# NGINX 1.26 Installation and Configuration Script for Ubuntu 22.04

This script automates the installation of NGINX 1.26 on Ubuntu 22.04 and configures it according to the [cocsirt-config-guide](https://github.com/inetspa/cocsirt-config-guide/blob/main/WebServer/nginx-1.26-install.md). It also allows you to configure upstream servers for worker nodes using ports 30080 and 30443 for an ingress controller, and it sets up virtual hosts, including one with SSL.

## Features

- **NGINX 1.26 Installation**: Installs NGINX 1.26 using the official NGINX repository.
- **Custom Configuration**: Downloads and applies a custom NGINX configuration based on the cocsirt-config-guide.
- **Upstream Configuration**: Prompts for the number of worker nodes and their IP addresses to configure upstream servers on ports 30080 and 30443.
- **SSL Configuration**: Sets up the first virtual host with SSL, using certificates located at `/etc/nginx/ssl/domain.crt` and `/etc/nginx/ssl/domain.key`.
- **Virtual Hosts**: Allows you to configure additional virtual hosts without SSL.

## Prerequisites

Before running the script, make sure your system meets the following requirements:

- Ubuntu 22.04
- Root or sudo privileges
- NGINX signing key added (handled by the script)
- SSL certificate and key files available at `/etc/nginx/ssl/domain.crt` and `/etc/nginx/ssl/domain.key` for the first SSL-enabled virtual host

## Usage

1. **Download the Script**: Save the script as `install_nginx_with_ssl_vhost.sh`.
2. **Make the Script Executable**: Run the following command to make the script executable:
    ```bash
    chmod +x install_nginx_with_ssl_vhost.sh
    ```
3. **Run the Script**: Execute the script with sudo to begin the installation and configuration process:
    ```bash
    sudo ./install_nginx_with_ssl_vhost.sh
    ```
4. **Follow the Prompts**: The script will prompt you for:
    - The number of worker nodes
    - IP addresses of the worker nodes
    - The server name (domain) and root directory for the SSL-enabled virtual host
    - Whether you want to add more virtual hosts without SSL

5. **Verify the Installation**: After the script completes, you can verify the NGINX status:
    ```bash
    sudo systemctl status nginx
    ```

## Example

### Basic Example

If you are configuring a single virtual host with SSL, the script will ask for:

- **Server Name**: `example.com`
- **Root Directory**: `/var/www/html/example`

The script will then create a configuration that secures `example.com` with SSL using the certificates located in `/etc/nginx/ssl/`.

### Adding Additional Virtual Hosts

The script will prompt you to add additional virtual hosts. If you choose to add another, you'll provide the server name and root directory, and the script will configure the new virtual host without SSL.

## Notes

- Make sure your SSL certificates are correctly placed in the `/etc/nginx/ssl/` directory before running the script.
- The script sets up an upstream block for load balancing across multiple worker nodes. Ensure that the IP addresses and ports provided during setup are correct.

## Troubleshooting

If you encounter any issues:

- Verify that the SSL certificate and key are correctly placed and named.
- Ensure that NGINX has the correct permissions to read the configuration files.
- Check the NGINX error logs located at `/var/log/nginx/error.log` for more details.

## License

This script is open-source and available under the MIT License. Feel free to modify and distribute as needed.
