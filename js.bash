#!/bin/bash
#Storyline: Setup Jump
function NetCon() {
#conf="00-installer-config.yaml"
conf="/etc/netplan/00-installer-config.yaml"
rm ${conf}
ip=172.16.50.4
netmask=29
gateway=172.16.50.2
ns=172.16.200.11
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
hostname="jump-nilesh"
#command to set hostname
hostname ${hostname}
}
function UserCon() {
uN="Nilesh"
uP="N!lesh@123"
adduser ${uN} ${uP}
adduser ${uN} sudo
}
function LogCon() {
echo "auth,authpriv.*@172.16.200.10:1514;RYSYLOG_SyslogProtocol23Format" >> etc/rsyslog.d/sec350.conf
systemctl restart rsyslog
}
SysCon
UserCon
NetCon
LogCon
