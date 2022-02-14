Network firewalls are security devices used to stop or mitigate unauthorized access to private networks connected to the Internet, especially intranets. The only traffic allowed on the network is defined via firewall policies – any other traffic attempting to access the network is blocked. Network firewalls sit at the front line of a network, acting as a communications liaison between internal and external devices.

A network firewall can be configured so that any data entering or exiting the network has to pass through it – it accomplishes this by examining each incoming message and rejecting those that fail to meet the defined security criteria. When properly configured, a firewall allows users to access any of the resources they need while simultaneously keeping out unwanted users, hackers, viruses, worms or other malicious programs trying to access the protected network.

## Why Network Firewalls are Important

Without firewalls, if a computer has a publicly addressable IP – for instance, if it is directly connected via ethernet – then any network service that is currently running on that device may become accessible to the outside world. Any computer network that is connected to the internet is also potentially at risk for an attack. Without a firewall, these networks become vulnerable to malicious attacks. For example:

* If your network is connected to the internet, some types of malware find ways to divert portions of your hardware’s bandwidth for its own purposes.
* Some types of malware are designed to gain access to your network to use sensitive information such as credit card info, bank account numbers or other proprietary data like customer information.
* Other types of malware are designed to simply destroy data or bring networks down.

For full-spectrum security, firewalls should be placed between any network that has a connection to the internet, and businesses should establish clear computer security plans, with policies on external networks and data storage.

In the cloud era, network firewalls can do more than secure a network. They can also help ensure that you have uninterrupted network availability and robust access to cloud-hosted applications.

# Lab 4.2 Network Firewalls 1

In this lab we are going to shut down and then manage traffic between the LAN, DMZ,WAN and MGMT Networks.

on the Windows Workstation:

```powershell
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow
```

💣There is both promise and peril in using the latest bleeding edge version of vyos and other operating systems. There was a logging flaw in the default vyos image for Spring 2022. We will update the vyos image to one that works. This section covers how to do so.

On Firewall:

```vyos
exit #if you're in config
add system image https://s3.amazonaws.com/s3-us.vyos.io/rolling/current/vyos-1.4-rolling-202202030910-amd64.iso
reboot
```

## Configuring fw01

Create and link firewall zones to interfaces (eth0, eth1, eth2)

```bash
configure
set zone-policy zone WAN interface eth0
set zone-policy zone DMZ interface eth1
set zone-policy zone LAN interface eth2
commit
save
```

A Zone-based firewall is an advanced method of the stateful firewall. In a stateful firewall, a stateful database is maintained in which source IP address, destination IP address, source port number, destination port number is recorded. Due to this, only the replies are allowed i.e if the traffic is Generated from inside the network then only the replies (of inside network traffic) coming from outside the network is allowed.

```bash
configure
set firewall name WAN-to-DMZ default-action drop
set firewall name WAN-to-DMZ enable-default-log
set firewall name DMZ-to-WAN default-action drop
set firewall name DMZ-to-WAN enable-default-log
set zone-policy zone DMZ from WAN firewall name WAN-to-DMZ
set zone-policy zone WAN from DMZ firewall name DMZ-to-WAN
commit
save
```

### Allow http traffic from the WAN to the DMZ based web01

```bash
configure
set firewall name WAN-to-DMZ rule 10 action accept
set firewall name WAN-to-DMZ rule 10 destination address 172.16.50.3
set firewall name WAN-to-DMZ rule 10 destination port 80
set firewall name WAN-to-DMZ rule 10 protocol tcp
set firewall name WAN-to-DMZ rule 10 description "Allow WAN Access to Web01 HTTP"
commit
save
tail /var/log/messages | grep DMZ
```

## Allowing established connections back out again

```bash
configure
set firewall name DMZ-to-WAN rule 1 action accept
set firewall name DMZ-to-WAN rule 1 state established enable
commit
save
show firewall name DMZ-to-WAN
```

## Creating default firewalls for LAN and DMZ and link them to zone policies

```bash
configure
set firewall name DMZ-to-LAN default-action drop
set firewall name DMZ-to-LAN enable-default-log
set firewall name LAN-to-DMZ default-action drop
set firewall name LAN-to-DMZ enable-default-log
set zone-policy zone LAN from DMZ firewall name DMZ-to-LAN
set zone-policy zone DMZ from LAN firewall name LAN-to-DMZ
commit
save
```

## Add a firewall rule 10 to the DMZ-TO-LAN firewall that allows UDP 1514 to go between DMZ to LAN

```bash
configure
set firewall name DMZ-to-LAN rule 10 action accept
set firewall name DMZ-to-LAN rule 10 destination address 172.16.200.10
set firewall name DMZ-to-LAN rule 10 destination port 1514
set firewall name DMZ-to-LAN rule 10 protocol udp
commit
save
```

## Create a firewall rule on DMZ-TO-LAN that allows established connections back through the firewall

```bash
configure
set firewall name LAN-to-DMZ rule 10 action accept
set firewall name LAN-to-DMZ rule 10 destination address 172.16.50.3
set firewall name LAN-to-DMZ rule 10 destination port 80
set firewall name LAN-to-DMZ rule 10 protocol tcp
set firewall name LAN-to-DMZ rule 10 description "Allow LAN access to Web01 HTTP"
commit
save
set firewall name DMZ-to-LAN rule 1 action accept
set firewall name DMZ-to-LAN rule 1 state established enable
commit
save
```

## Firewall rule for LAN-to-WAN

```bash
configure
set firewall name LAN-to-WAN default-action drop
set firewall name LAN-to-WAN enable-default-log
set firewall name LAN-to-WAN rule 1 action accept
commit
save
show firewall name LAN-to-WAN
```

## Create WAN-TO-LAN firewall

```bash
configure
set firewall name WAN-to-LAN default-action drop
set firewall name WAN-to-LAN enable-default-log
set firewall name WAN-to-LAN rule 1 action accept
set firewall name WAN-to-LAN rule 1 state established enable
set zone-policy zone WAN from LAN firewall name LAN-to-WAN
set zone-policy zone LAN from WAN firewall name WAN-to-LAN
commit
save
```

## Configuring MGMT firewall

It is important to have proper network segmentation for security reasons.

Create both zones and assign the correct interfaces.

Create a LAN-TO-MGMT firewall that:

Allows 1514/udp to from LAN to log01

Allows ICMP to log01 from LAN (here’s a hint: because we haven’t created ICMP rules before)

```bash
configure
set zone-policy zone LAN interface eth0
set zone-policy zone MGMT interface eth1
set firewall name LAN-to-MGMT default-action drop
set firewall name LAN-to-MGMT enable-default-log
set firewall name MGMT-to-LAN default-action drop
set firewall name MGMT-to-LAN enable-default-log
set firewall name MGMT-to-LAN rule 1 action accept
set zone-policy zone MGMT from LAN firewall name LAN-to-MGMT
set zone-policy zone LAN from MGMT firewall name MGMT-to-LAN
set firewall name LAN-to-MGMT rule 10 action accept
set firewall name LAN-to-MGMT rule 10 destination address 172.16.200.10
set firewall name LAN-to-MGMT rule 10 destination port 1514
set firewall name LAN-to-MGMT rule 10 protocol udp
set firewall name LAN-to-MGMT rule 15 action accept
set firewall name LAN-to-MGMT rule 15 destination address 172.16.200.10
set firewall name LAN-to-MGMT rule 15 protocol icmp
set firewall name LAN-to-MGMT rule 1 action accept
set firewall name LAN-to-MGMT rule 1 state established enable
commit
save
```

## Reflection

I felt that this lab took longer than I expected it to. I found out that drawing zones and interfaces can help me setup this stuff much faster than normal. It was confusing however to remember all of that syntax for rules.
