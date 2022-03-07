#!/bin/bash
#Storyline: Setup Nginx
function NetCon() {
#conf="00-installer-config.yaml"
conf="/etc/netplan/00-installer-config.yaml"
rm ${conf}
ip=172.16.50.5
netmask=29
gateway=172.16.50.2
ns=172.16.50.2
#echo the contents onto a file
echo "
network:
   version: 2
   renderer: networkd
   ethernets:
      ens160:
         dhcp4: false
         addresses: [${ip}/${netmask}]
         gateway4: ${gateway}
         nameservers:
           addresses: [${ns}]
" >> ${conf}
netplan apply
}
function SysCon() {
hostname="nginx01-nilesh"
#command to set hostname
hostname ${hostname}
}
function UserCon() {
uN="Nilesh"
uP="N!lesh@123"
useradd -m ${uN} -p ${uP}
usermod -aG sudo ${uN}
}
function LogCon() {
echo "auth,authpriv.*@172.16.200.10:1514;RYSYLOG_SyslogProtocol23Format" >> /etc/rsyslog.d/sec350.conf
systemctl restart rsyslog
}
function nginx() {
apt --assume-yes install nginx
ufw allow 'Nginx HTTP'
ufw disable
ufw enable
echo "
<html>
<head>
<title>Internal Script</title>
</head>
<body>
<h1>
   Hello Devin
</h1>
</body>
</html>
" >> /var/www/html/index.html
systemtctl restart nginx
}
SysCon
UserCon
NetCon
LogCon
nginx
