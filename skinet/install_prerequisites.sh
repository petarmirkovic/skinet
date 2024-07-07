#!/bin/bash

# Update the package list
apt update

# Install nodejs and npm
apt install -y nodejs npm

# Install Angular CLI globally
npm install -g @angular/cli@15

# Download Microsoft signing key and add Microsoft package repository
mkdir -p /etc/apt/keyrings
wget https://packages.microsoft.com/keys/microsoft.asc -O /etc/apt/keyrings/microsoft.key
wget https://packages.microsoft.com/config/debian/12/prod.list -O /etc/apt/sources.list.d/msprod.list

# Edit msprod.list to comment the present line and add the new line
sed -i 's/^/#/' /etc/apt/sources.list.d/msprod.list
echo 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.key] https://packages.microsoft.com/debian/12/prod bookworm main' >> /etc/apt/sources.list.d/msprod.list

# Update the package list again
apt update

# Install .NET SDK and build-essential
apt -y install dotnet-sdk-7.0 build-essential

# Update the package list once more
apt update

# Install necessary packages for Docker
apt install -y ca-certificates curl gnupg apt-transport-https gpg

# Add Docker's official GPG key and set up the stable repository
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list yet again
apt update

# Install Docker packages
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
