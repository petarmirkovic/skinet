#!/bin/bash

# Download the Node Exporter tarball
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz

# Extract the tarball
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz

# Move the binary to /usr/local/bin/
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Create the systemd service file
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=default.target
EOF

# Create a new user for Node Exporter
sudo useradd -rs /bin/false node_exporter

# Reload systemd to pick up the new service
sudo systemctl daemon-reload

# Start the Node Exporter service
sudo systemctl start node_exporter

# Enable the service to start on boot
sudo systemctl enable node_exporter
# Add iptables rules to allow traffic on port 9100
sudo iptables -I OUTPUT -p tcp --sport 9100 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 9100 -j ACCEPT
