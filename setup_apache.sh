#!/bin/bash

# Update package index
apt update

# Install Apache
apt install -y apache2

# Enable necessary Apache modules
a2enmod proxy proxy_http proxy_html rewrite

# Restart Apache
systemctl restart apache2

# Check Apache status
systemctl status apache2

# Adjust iptables rules for ports 5432 and 8081
iptables -I OUTPUT -p tcp --sport 5432 -j ACCEPT
iptables -I INPUT -p tcp --dport 5432 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 8081 -j ACCEPT
iptables -I INPUT -p tcp --dport 8081 -j ACCEPT

# Add VirtualHost configurations
tee /etc/apache2/sites-available/skinet.conf > /dev/null <<EOF

<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ProxyPreserveHost On
  ProxyPass / http://10.10.10.151:5000/
  ProxyPassReverse / http://10.10.10.151:5000/
  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the site configuration
a2ensite skinet

# List enabled sites
ls /etc/apache2/sites-enabled

# Disable default site
a2dissite 000-default

# Reload Apache configuration
systemctl reload apache2

echo "Apache setup completed."
