# Assessment (Human Code for Nile.sh version 06032021) SEC350

Calm down you got this

No fr you do you're chill

Recommended Playlist: [YouTube Music](https://music.youtube.com/watch?v=w4g0EkWCeDs&feature=share) (Speed multiplier: 1.07)

RW01

WEB01

FW01

no longer exist, instead we have

nginx01

traveller01

edge01

dhcp01



## Setup Edge01

Along the setup, we will mess around with edge01 alot. This is the initial setup for edge01. The idea is to bring it up to speed with exactly where we left off with fw01.

Make sure the network adapters are connected properly.

NetAdapter1:WAN

NetAdapter2: DMZ

NetAdapter3: LAN

Now figure a way out to get scripts onto this damn thing remember fw01 is gone so getting the script from wks will be hard. None of your network has internet so the script will have to be uploaded another way.

This is the script for bringing Edge01 to FW01

```bash
#!/bin/vbash
#storyline: setup edge01
set firewall name DMZ-to-LAN default-action 'drop'
set firewall name DMZ-to-LAN enable-default-log
set firewall name DMZ-to-LAN rule 1 action 'accept'
set firewall name DMZ-to-LAN rule 1 state established 'enable'
set firewall name DMZ-to-LAN rule 10 action 'accept'
set firewall name DMZ-to-LAN rule 10 destination address '172.16.200.10'
set firewall name DMZ-to-LAN rule 10 destination port '1514'
set firewall name DMZ-to-LAN rule 10 protocol 'udp'
set firewall name DMZ-to-WAN default-action 'drop'
set firewall name DMZ-to-WAN enable-default-log
set firewall name DMZ-to-WAN rule 1 action 'accept'
set firewall name DMZ-to-WAN rule 1 state established 'enable'
set firewall name DMZ-to-WAN rule 10 action 'accept'
set firewall name DMZ-to-WAN rule 10 description 'allow web01 to connect to 123udp'
set firewall name DMZ-to-WAN rule 10 destination port '123'
set firewall name DMZ-to-WAN rule 10 protocol 'udp'
set firewall name DMZ-to-WAN rule 10 source address '172.16.50.3'
set firewall name LAN-to-DMZ default-action 'drop'
set firewall name LAN-to-DMZ enable-default-log
set firewall name LAN-to-DMZ rule 10 action 'accept'
set firewall name LAN-to-DMZ rule 10 description 'Allow LAN access to Web01 HTTP'
set firewall name LAN-to-DMZ rule 10 destination address '172.16.50.3'
set firewall name LAN-to-DMZ rule 10 destination port '80'
set firewall name LAN-to-DMZ rule 10 protocol 'tcp'
set firewall name LAN-to-DMZ rule 20 action 'accept'
set firewall name LAN-to-DMZ rule 20 destination address '172.16.50.1-172.16.50.6'
set firewall name LAN-to-DMZ rule 20 destination port '22'
set firewall name LAN-to-DMZ rule 20 protocol 'tcp'
set firewall name LAN-to-DMZ rule 20 source address '172.16.200.11'
set firewall name LAN-to-DMZ rule 30 action 'accept'
set firewall name LAN-to-DMZ rule 30 description 'Allow LAN access to web01'
set firewall name LAN-to-DMZ rule 30 destination address '172.16.50.1-172.16.50.6'
set firewall name LAN-to-DMZ rule 30 destination port '22'
set firewall name LAN-to-DMZ rule 30 protocol 'tcp'
set firewall name LAN-to-DMZ rule 30 source address '172.16.200.11'
set firewall name LAN-to-DMZ rule 30 source port '22'
set firewall name LAN-to-MGMT default-action 'drop'
set firewall name LAN-to-MGMT enable-default-log
set firewall name LAN-to-MGMT rule 1 action 'accept'
set firewall name LAN-to-MGMT rule 1 state established 'enable'
set firewall name LAN-to-MGMT rule 10 action 'accept'
set firewall name LAN-to-MGMT rule 10 destination address '172.16.200.10'
set firewall name LAN-to-MGMT rule 10 destination port '1514'
set firewall name LAN-to-MGMT rule 10 protocol 'udp'
set firewall name LAN-to-MGMT rule 15 action 'accept'
set firewall name LAN-to-MGMT rule 15 destination address '172.16.200.10'
set firewall name LAN-to-MGMT rule 15 protocol 'icmp'
set firewall name LAN-to-WAN default-action 'drop'
set firewall name LAN-to-WAN enable-default-log
set firewall name LAN-to-WAN rule 1 action 'accept'
set firewall name MGMT-to-LAN default-action 'drop'
set firewall name MGMT-to-LAN enable-default-log
set firewall name MGMT-to-LAN rule 1 action 'accept'
set firewall name WAN-to-DMZ default-action 'drop'
set firewall name WAN-to-DMZ enable-default-log
set firewall name WAN-to-DMZ rule 10 action 'accept'
set firewall name WAN-to-DMZ rule 10 description 'Allow WAN access to Web01 HTTP'
set firewall name WAN-to-DMZ rule 10 destination address '172.16.50.3'
set firewall name WAN-to-DMZ rule 10 destination port '80'
set firewall name WAN-to-DMZ rule 10 protocol 'tcp'
set firewall name WAN-to-DMZ rule 20 action 'accept'
set firewall name WAN-to-DMZ rule 20 description 'allow established connections'
set firewall name WAN-to-DMZ rule 20 state established 'enable'
set firewall name WAN-to-DMZ rule 30 action 'accept'
set firewall name WAN-to-DMZ rule 30 description 'Allow WAN to ssh to jump'
set firewall name WAN-to-DMZ rule 30 destination address '172.16.50.4'
set firewall name WAN-to-DMZ rule 30 destination port '22'
set firewall name WAN-to-DMZ rule 30 protocol 'tcp'
set firewall name WAN-to-LAN default-action 'drop'
set firewall name WAN-to-LAN enable-default-log
set firewall name WAN-to-LAN rule 1 action 'accept'
set firewall name WAN-to-LAN rule 1 state established 'enable'
set interfaces ethernet eth0 address 'dhcp'
set interfaces ethernet eth0 address '10.0.17.120/24'
set interfaces ethernet eth0 description 'SEC350-WAN'
set interfaces ethernet eth0 hw-id '00:50:56:b3:42:9d'
set interfaces ethernet eth1 address 'dhcp'
set interfaces ethernet eth1 address '172.16.50.2/29'
set interfaces ethernet eth1 description 'NILE-DM2'
set interfaces ethernet eth1 hw-id '00:50:56:b3:08:a7'
set interfaces ethernet eth2 address '172.16.150.2/24'
set interfaces ethernet eth2 description 'NILE-LAN'
set interfaces ethernet eth2 hw-id '00:50:56:b3:bc:d4'
set interfaces loopback lo
set nat destination rule 10 description 'NAT from HTTP to web01'
set nat destination rule 10 destination port '80'
set nat destination rule 10 inbound-interface 'eth0'
set nat destination rule 10 protocol 'tcp'
set nat destination rule 10 translation address '172.16.50.3'
set nat destination rule 10 translation port '80'
set nat destination rule 30 description 'Port forwarding ssh to jump'
set nat destination rule 30 destination port '22'
set nat destination rule 30 inbound-interface 'eth0'
set nat destination rule 30 protocol 'tcp'
set nat destination rule 30 translation address '172.16.50.4'
set nat destination rule 30 translation port '22'
set nat source rule 10 description 'NAT FROM DMZ to WAN'
set nat source rule 10 outbound-interface 'eth0'
set nat source rule 10 source address '172.16.50.0/29'
set nat source rule 10 translation address 'masquerade'
set nat source rule 15 description 'NAT from DMZ to LAN'
set nat source rule 15 outbound-interface 'eth0'
set nat source rule 15 source address '172.16.150.0/24'
set nat source rule 15 translation address 'masquerade'
set nat source rule 20 description 'NAT FROM MGMT to WAN'
set nat source rule 20 outbound-interface 'eth0'
set nat source rule 20 source address '172.16.200.0/28'
set nat source rule 20 translation address 'masquerade'
set protocols rip interface eth2
set protocols rip network '172.16.50.0/29'
set protocols static route 0.0.0.0/0 next-hop 10.0.17.2
set service dns forwarding allow-from '172.16.50.0/29'
set service dns forwarding allow-from '172.16.150.0/24'
set service dns forwarding listen-address '172.16.50.2'
set service dns forwarding listen-address '172.16.150.2'
set service dns forwarding system
set service ssh listen-address '172.16.150.2'
set system config-management commit-revisions '100'
set system conntrack modules ftp
set system conntrack modules h323
set system conntrack modules nfs
set system conntrack modules pptp
set system conntrack modules sip
set system conntrack modules sqlnet
set system conntrack modules tftp
set system console device ttyS0 speed '115200'
set system host-name 'fw1-nile'
set system login user nile authentication encrypted-password '$6$Aytlu73YzbaM/4UU$icOPIuLz1t5sPDfvsGfuTBAzj1ke5o1GTigaIWkJx6iLv5lWU/UDfOrHfj6Kubx8nGlhC/Mea5EiEx46o5HtM1'
set system login user vyos authentication encrypted-password '$6$mf19vObjaWPFXBss$atQjHUYcQ4jcoh0uqJUwX.ODdXdeyhMubm6MSjO9X1TlfNMq5keBseECRfAu.e.9CGaW2p3Pjiblj5ax.wjMG1'
set system login user vyos authentication plaintext-password ''
set system name-server '10.0.17.2'
set system ntp server time1.vyos.net
set system ntp server time2.vyos.net
set system ntp server time3.vyos.net
set system syslog host 172.16.200.10 facility kern level 'debug'
set system syslog host 172.16.200.10 format octet-counted
set system syslog host 172.16.200.10 port '1514'
set zone-policy zone DMZ from LAN firewall name 'LAN-to-DMZ'
set zone-policy zone DMZ from WAN firewall name 'WAN-to-DMZ'
set zone-policy zone DMZ interface 'eth1'
set zone-policy zone LAN from DMZ firewall name 'DMZ-to-LAN'
set zone-policy zone LAN from WAN firewall name 'WAN-to-LAN'
set zone-policy zone LAN interface 'eth2'
set zone-policy zone WAN from DMZ firewall name 'DMZ-to-WAN'
set zone-policy zone WAN from LAN firewall name 'LAN-to-WAN'
set zone-policy zone WAN interface 'eth0'
```

This should work and now the host name should be back to fw1-nile . good lmao

## Setup Nginx

This is the easiest part of the lab, I'm going to script it anyway cause I am lazy.

```bash
#!/bin/bash
#Storyline: Setup Nginx
function NetCon() {
#conf="00-installer-config.yaml"
conf="/etc/netplan/00-installer-config.yaml"
rm ${conf}
ip=172.16.50.5
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
echo "auth,authpriv.*@172.16.200.10:1514;RYSYLOG_SyslogProtocol23Format" >> etc/rsyslog.d/sec350.conf
systemctl restart rsyslog
}
function nginx() {
apt install nginx -Y
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
```

### Nginx VBASH shtick

You're doing great, you're chill

Now we'll have to make some changes to the edge01 to achieve our goal the web server being setup.

```bash
#!/bin/vbash
#storyline: Setup nginx on edge
config
#make sure it can connect to the internet
set firewall name DMZ-to-WAN rule 20 action accept
set firewall name DMZ-to-WAN rule 20 description "allow nginx01 to connect to the web"
set firewall name DMZ-to-WAN rule 20 source address 172.16.50.5
#shitty firewall stuff
set firewall name LAN-to-DMZ default-action-drop
set firewall name LAN-to-DMZ enable-default-log
set firewall name LAN-to-DMZ rule 10 action accept
set firewall name LAN-to-DMZ rule 10 description "allow LAN access to nginx01"
set firewall name LAN-to-DMZ rule 10 destination address 172.16.50.5
set firewall name LAN-to-DMZ rule 10 destination port 80
set firewall name LAN-to-DMZ rule 10 protocol tcp
set firewall name LAN-to-DMZ rule 20 action accept
set firewall name LAN-to-DMZ rule 20 description "allow mgmt access to nginx01"
set firewall name LAN-to-DMZ rule 20 destination address 172.16.50.5
set firewall name LAN-to-DMZ rule 20 destination port 22
set firewall name LAN-to-DMZ rule 20 protocol tcp
set firewall name LAN-to-DMZ rule 20 source address 172.16.200.11
set firewall name LAN-to-DMZ rule 30 action accept
set firewall name LAN-to-DMZ rule 30 description "allow ping from nginx to log01"
set firewall name LAN-to-DMZ rule 30 destination address 172.16.50.5
set firewall name LAN-to-DMZ rule 30 protocol icmp
set firewall name LAN-to-DMZ rule 30 source address 172.16.200.10
commit
save
```

Now your web server should be accessible by the machines on the network. Check with mgmt or wks.



## DHCP ki maa ki

 See I told you you're chill

Make sure the network adapter is on lan.

Now we have to setup this new DHCP server. Because I am lazy I will be scripting this.

```bash
#!/bin/bash
#Storyline: Setup DHCP
function NetCon() {
#conf="00-installer-config.yaml"
conf="/etc/netplan/00-installer-config.yaml"
rm ${conf}
ip=172.16.150.5
netmask=24
gateway=172.16.150.2
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
hostname="dhcp01-nilesh"
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
echo "local0,auth,authpriv.*@172.16.200.10:1514;RYSYLOG_SyslogProtocol23Format" >> etc/rsyslog.d/sec350.conf
systemctl restart rsyslog
}
function dhcpSetup() {
apt install isc-dhcp-server
rm /etc/dhcp/dhcpd.conf
echo "
# a simple /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;
log-facility local0;

subnet 172.16.150.0 netmask 255.255.255.0 {
 range 172.16.150.100 172.16.150.150;
 option routers 172.16.150.2;
}
" >> /etc/dhcp/dhcpd.conf
systemctl restart dhcpd
firewall-cmd --add-service=dhcp --permanent
firewall-cmd --reload
}
SysCon
UserCon
NetCon
LogCon
dhcpSetup
```

Now your dhcp should be setup.

Go to WKS01 and run this to enable dhcp or just change through the gui.

```powershell
$IPType = "IPv4"
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
$interface = $adapter | Get-NetIPInterface -AddressFamily $IPType
If ($interface.Dhcp -eq "Disabled") {
 # Remove existing gateway
 If (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $interface | Remove-NetRoute -Confirm:$false
 }
 # Enable DHCP
 $interface | Set-NetIPInterface -DHCP Enabled
 # Configure the DNS Servers automatically
 $interface | Set-DnsClientServerAddress -ResetServerAddresses
}
```

Now wks01 should have dhcp.

## Traveller01 (RW01 billy gates remix)

You're chill, I told you so.

This is basically a machine that replaces rw01.

IP: 10.0.17.20

The otherthing: 10.0.17.147

Firewall configs if they're not already working.

```bash
#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# set up LAN to WAN rules 
configure
set firewall name LAN-WAN default-action drop
set firewall name LAN-WAN enable-default-log
set firewall name LAN-WAN rule 1 action accept
commit 
save

# set up WAN to LAN rules
configure
set firewall name WAN-LAN default-action drop
set firewall name WAN-LAN enable-default-log
set firewall name WAN-LAN rule 1 action accept
commit 
save

# Allow logs from web01 to log server DMZ-LAN
configure
set firewall name DMZ-LAN default-action drop
set firewall name DMZ-LAN enable-default-log
set firewall name DMZ-LAN rule 10 action accept
set firewall name DMZ-LAN rule 10 destination port 1514
set firewall name DMZ-LAN rule 10 protocol udp
set firewall name DMZ-LAN rule 20 action accept
set firewall name DMZ-LAN rule 20 state established enable
commit
save

exit
```




