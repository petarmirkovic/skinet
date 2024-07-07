# **Application Deployment Guide**

## Network Architecture Diagram
Below you can find a simplified diagram illustrating the network setup for deploying SkiNet application:
![network_diagram](https://gitlab.com/pesicgroup/skinet/-/raw/main/Screenshot_2024-07-07_164744.png?raw=true)

## Internal IP table

| no | hostname | IP address |
|-| -- | ------ |
|1| virt-router | 10.10.10.1 |
|2| opnsense-vpn | 10.10.10.101 |
|3| apache2-lb | 10.10.10.150 |
|4| skinet | 10.10.10.151 |
|5| skinet-monitoring | 10.10.10.249 |

1. **virt-router** serves as a MikroTik router connecting to our provider's network, establishing VLANs for the Skinet application, and performing NAT to direct traffic to our Apache2 server.
2. **opnsense-vpn** enables SSH connectivity to our virtual machines, ensuring secure remote access.
3. **apache2-lb** functions as a load balancer, directing traffic across all application modules.
4. **skinet-monitoring** is where Grafana, Prometheus, and cAdvisor are deployed. They're used as monitoring solution for the Skinet server.

## Steps to Deploy the Application
### Step 1. Pull the project on main app virtual machine (skinet)
### Step 2. Install prerequisites
In the application folder, there's a prerequisites.sh script that installs all necessary components like Node, NVM, Angular, etc. To make this script executable, use the command "chmod +x install_prerequisites.sh", then run the script with "./install_prerequisites.sh".
### Step 3. Deploy application
1. Into the main folder there's setup_apache.sh script, copy it to apache2-lb vm (or skinet vm if you want to save resources). Make this script executable with _chmod +x setup_apache.sh_ command and run it with _sudo ./setup_apache.sh_ command.
2. SSH into skinet vm and run the following:
dotnet publish -c Release -o publish skinet.sln  
dotnet ef database drop -s API -p .\Infrastructure\ -c StoreContext  
dotnet ef database drop -s API -p .\Infrastructure\ -c AppIdentityDbContext  
dotnet watch --no-hot-reload

Into the skinet folder you can find docker-compose.yml file, start it with _docker-compose up -d_ command.
After that, create directory for application:  
sudo mkdir /var/skinet  
sudo chown -R `$USER:$USER /var/skinet`  

Copy/move files from skinet folder into newly created folder /var/skinet.  
Run _dotnet publish -c Release -o publish Skinet.sln_ - This will create a new folder called publish.

Restart the journalist service: _systemctl restart systemd-journald_;
Set up the service that will run the kestrel web server: _sudo nano /etc/systemd/system/skinet-web.service_
Paste in the folllowing:

[Unit]
Description=Kestrel service running on Ubuntu 18.04
[Service]
WorkingDirectory=/var/skinet
ExecStart=/usr/bin/dotnet /var/skinet/API.dll
Restart=always
RestartSec=10
SyslogIdentifier=skinet
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment='Token__Key=CHANGE ME TO SOMETHING SECURE'
Environment='Token__Issuer=https://yoursitegoeshere'
[Install]
WantedBy=multi-user.target

then run sudo systemctl enable skinet-web.service; sudo systemctl start skinet-web.service; (without ;)
Ensure the server is running: netstat -ntpl
Check the journal logs: journalctl -u skinet-web.service --since "5 min ago"

### Enjoy SkiNet application: Sample bellow:


##Steps to Deploy monitoring

# **Monitoring Deployment Guide**
### Step 1. Install node exporter on skinet VM (NOTE: Login as root)
Pull project. cd into the monitoring folder, there's a prerequisites.sh script that installs and set up node exporter and open ports so prometheus can scrape metrics.
Make script executable with _chmod +x install_node_exporter.sh_ command and start it with ./install_node_exporter.sh.
### Step 2. Grafana/Prometheus install
Monitoring system is configured that docker-compose.yml with coresponding files deploy simple monitoring.
Monitoring can be deployed by running _docker-compose up_ command.
If anything goes wrong (or you edited configuration and want to rerun it) start _docker-compose rm -f_ or mannualy delete all of the containers that can be seen with _docker ps -a_ then rerun it with docker-compose up --build.
### Open ports for Grafana/Prometheus on monitoring machine
iptables -I OUTPUT -p tcp --sport 3000 -j ACCEPT  
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT  
iptables -I OUTPUT -p tcp --sport 9090 -j ACCEPT  
iptables -I INPUT -p tcp --dport 9090 -j ACCEPT  
### Access Grafana
Access grafana on http://server_IP:3000 (In our case server_IP = 10.10.10.249)
### Extra: Grafana monitoring sample:
![network_diagram](https://gitlab.com/pesicgroup/skinet/-/raw/main/Screenshot_2024-07-07_195037.png?raw=true)