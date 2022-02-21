# Lab 5.1 - Logging Firewall Traffic

💡In this lab we are going to begin pushing firewall deny logs from both fw1 and fw-mgmt to GrayLog running on log01. We will leverage GrayLog to inform our firewall traffic management decisions.

A firewall, at its most basic form, is created to stop connections from suspicious networks. It inspects the source address, destination address, and the destination port of all connections, and decides if a network can be trusted.

For simplicity, we can aggregate information on the source address, source port, and destination address and port. We can view this information as an identifying quality of any attempt to connect, as tracked by the firewall.

This quality is similar to a set of rules that determine which connections are permitted and which must be denied. If this identifying quality holds information that is the same as a permitted connection, then the source address can create a connection with the destination address on the permitted port. Thus, the traffic is allowed into the network.

The success of any firewall, therefore, typically relies on the rules used to configure it.

The firewall monitors traffic into and out of the environment it was created to safeguard and provides visibility into the type and source of traffic entering this environment. It typically serves two purposes:

* Protecting the environment from threats from internal and external (Internet) sources
* Acting as an investigative resource for security professionals who need to track how a breach penetrated the firewall

To be most effective, a firewall ruleset must be augmented with a successful logging feature.

The logging feature documents how the firewall deals with traffic types. These logs offer insights into, for example, source and destination IP addresses, protocols, and port numbers.

**When and why firewall logging is useful**

* To see if new firewall rules work well or to debug them if they do not work properly.

* To discover if any malicious activity is occurring within your network. However, it doesn’t offer the information you need to isolate the source of the activity.

* If you identify repeated unsuccessful tries to access your firewall from a single IP address (or from a group of IP addresses), you may wish to create a rule to stop all connections from that IP.

* Outgoing connections derived from internal servers, for example, web servers, may show that someone is using your system as a launch pad. They could be launching attacks against computers on other networks from your system.

## Accessing fw01-nilesh from MGMT

```bash
configure
show service ssh
delete service ssh listen-address
set service ssh listen-address 172.16.150.2
set service ssh loglevel verbose
commit
save
show service ssh
```

on mgmt1, using powershell ssh into fw01

```bash
ssh vyos@172.16.150.2
```

## Logging of Firewall denied traffic.

💡Tailing /var/log/messages on fw01 and fw-mgmt is not as effective as evaluating these same logs in GrayLog.

fw01:

```bash
logger -n 172.16.200.10 -P 1514 -t testfromfw01 message in a bottle
```

* on mgmt, ssh'ed into fw01, in powershell

```bash
configure
show system syslog host
delete system syslog host
set system syslog host 172.16.200.10
set system syslog host 172.16.200.10 facility kern level debug
set system syslog host 172.16.200.10 format octet-counted
set system syslog host 172.16.200.10 port 1514
commit
save
show system syslog host
sudo systemctl restart rsyslog
```

* on rw01, go to terminal

```bash
ssh root@172.16.50.3
^c
#this is supposed to fail
```

Make sure that fw-mgmt is only listening for ssh connections on it's MGMT interface. Apply the same syslog configuration as that applied to fw01.

Attempt an RDP session from wks1 to mgmt01. This should fail.

fw-mgmt:

```bash
configure
show service ssh
#if stuff is there, delete it
delete service ssh listen-address
set service ssh listen-address 172.16.200.2
set service ssh loglevel verbose
commit
save
show service ssh
show system syslog host
#if stuff is there, delete it
delete system syslog host
set system syslog host 172.16.200.10
set system syslog host 172.16.200.10 facility kern level debug
set system syslog host 172.16.200.10 format octet-counted
set system syslog host 172.16.200.10 port 1514
commit
save
show system syslog host
sudo systemctl restart rsyslog
```

go to wks1,

Attempt an RDP session from wks1 to mgmt01 to create a log for a failed attempt.

## Allowing Management Traffic

It is important that the management can acccess web01 to make changes to it. We will now setup a rule for the ssh connection in the firewall-management.

fw-mgmt:

```bash
#make firewall rule
configure
set firewall name MGMT-to-DMZ rule 10 action accept
set firewall name MGMT-to-DMZ rule 10 source address 172.16.200.11
set firewall name MGMT-to-DMZ rule 10 destination address 172.16.50.3
set firewall name MGMT-to-DMZ rule 10 destination port 22
set firewall name MGMT-to-DMZ rule 10 protocol tcp
commit
save
show firewall name MGMT-to-DMZ rule 10
#allow traffic
set firewall name DMZ-to-MGMT rule 1 action accept
set firewall name DMZ-to-MGMT rule 1 state established enable
commit
save
```

on fw01

```bash
configure
set firewall name LAN-to-DMZ rule 20 action accept
set firewall name LAN-to-DMZ rule 20 source address 172.16.200.11
set firewall name LAN-to-DMZ rule 20 destination address 172.16.50.3
set firewall name LAN-to-DMZ rule 20 destination port 22
set firewall name LAN-to-DMZ rule 20 protocol tcp
commit
save
```

fw-mgmt:

```bash
configure
show nat
#needs to be deleted
delete nat source rule {$ruleNumber}
commit
save
```

This should allow SSH from mgmt01 to web01.

## Allowing Network Time Protocol

💡As we immerse ourselves into network denied traffic we will quickly realized that web01 really wants to know what time it is. We have very restrictive firewall rules from WAN-TO-DMZ but they need to be relaxed for some classes of traffic such as NTP.

Network Time Protocol (NTP) is a protocol designed to time-synchronize a network of machines. NTP runs on User Datagram Protocol (UDP), which in turn runs on IP. NTP Version 3 is documented in RFC 1305.

An NTP network usually gets its time from an authoritative time source such as a radio clock or an atomic clock attached to a time server. NTP then distributes this time across the network. NTP is extremely efficient; no more than one packet per minute is necessary to synchronize two machines to the accuracy of within a millisecond of one another.

NTP uses the concept of a stratum to describe how many NTP hops away a machine is from an authoritative time source. A stratum 1 time server typically has an authoritative time source (such as a radio or atomic clock, or a Global Positioning System (GPS) time source) directly attached, a stratum 2 time server receives its time via NTP from a stratum 1 time server, and so on.

NTP has two ways to avoid synchronizing to a machine whose time may not be accurate. NTP will never synchronize to a machine that is not in turn synchronized. NTP will compare the time reported by several machines, and will not synchronize to a machine whose time is significantly different from others, even if its stratum is lower. This strategy effectively builds a self-organizing tree of NTP servers.

The Cisco implementation of NTP does not support stratum 1 service; that is, you cannot connect to a radio or atomic clock (for some specific platforms, however, you can connect to a GPS time-source device). Cisco recommends that the time service for your network be derived from the public NTP servers available in the IP Internet.

If the network is isolated from the Internet, the Cisco implementation of NTP allows a machine to be configured so that it acts as though it is synchronized via NTP, when in fact it has determined the time using other means. Other machines can then synchronize to that machine via NTP.

A number of manufacturers include NTP software for their host systems and a publicly available version for systems running UNIX. This software also allows UNIX-derivative servers to acquire the time directly from an atomic clock, which would subsequently propagate time information along to Cisco routers.

The communications between machines running NTP (known as associations) are usually statically configured; each machine is given the IP address of all machines with which it should form associations. Accurate timekeeping is made possible through exchange of NTP messages between each pair of machines with an association.

However, in a LAN environment, NTP can be configured to use IP broadcast messages instead. This alternative reduces configuration complexity because each machine can be configured to send or receive broadcast messages. However, the accuracy of timekeeping is marginally reduced because the information flow is one-way only.

The time kept on a machine is a critical resource, so Cisco strongly recommends that you use the security features of NTP to avoid the accidental or malicious setting of incorrect time. Two mechanisms are available: an access list-based restriction scheme and an encrypted authentication mechanism.

When multiple sources of time (Virtual Integrated Network System (VINES), hardware clock, manual configuration) are available, NTP is always considered to be more authoritative. NTP time overrides the time set by any other method.

NTP services are disabled on all interfaces by default.

Create a DMZ-TO-WAN rule that allows web01 to connect to 123/udp, ensure that established connections are allowed back in again via the WAN-TO-DMZ rule.

fw-mgmt:

```bash
configure
set firewall name DMZ-to-WAN rule 10 description "allow web01 to update network time"
set firewall name DMZ-to-WAN rule 10 action accept
set firewall name DMZ-to-WAN rule 10 destination address 172.16.50.3
set firewall name DMZ-to-WAN rule 10 source port 123
set firewall name DMZ-to-WAN rule 10 protocol udp
set firewall name WAN-to-DMZ rule 1 action accept
set firewall name WAN-to-DMZ rule 1 state established enable
commit
save
```

fw-01:

```bash
configure 
set firewall name DMZ-to-WAN rule 10 description "allow web01 to update network time" 
set firewall name DMZ-to-WAN rule 10 action accept set firewall name DMZ-to-WAN rule 10 source address 172.16.50.3 
set firewall name DMZ-to-WAN rule 10 destination port 123 
set firewall name DMZ-to-WAN rule 10 protocol udp 
set firewall name WAN-to-DMZ rule 20 action accept 
set firewall name WAN-to-DMZ rule 20 state established enable 
commit 
save
```

Web01:

```bash
sudo systemctl restart chronyd sudo chronyc.sources
```

# Lab 5.2 - Windows Logging

* 💡Windows Logging is complex, if you look in any event log, you will notice right away that the verbosity of a Windows Application, Security or System Event is far greater than that of the humble syslog message. Ingesting these logs into systems such as splunk or graylog is also an adventure in systems administration. A suitable input needs to be configured in GrayLog and a log monitoring agent needs to be installed on GrayLog.

## Windows Time

🕐 Time is often an issue when a system uses Kerberos for authentication. Time skew can prevent login and results in hard to debug errors. For this reason, before you install ADDS/DNS, always, always make sure your server has an accurate source of time. The server itself becomes the source of time domain joined systems. The following illustrates the administrative commands necessary to make this happen. For you motivated individuals, you can find the powershell equivalent.

Mgmt01: (*admin*)

```powershell
w32tm /config /syncfromflags:manual /manualpeerlist:pool.ntp.org
net stop w32time
net start w32time
w32tm /resync
w32tm /query /source
```

* Install Active Directory Domain Services and DNS services on mgmt01
* * Domain: yourname.local
* * hostname: can remain as mgmt01

## LAN-to-MGMT

💡In order to be a domain member system, an exceptional number of ports are needed to include a large number of port ranges that vary from connection to connection. We will need to rely on our mgmt01's host based firewall for a good deal of enforcement where our stateful filtering falls short.

Create a LAN-TO-MGMT firewall rule that allows 172.16.150.50 - 172.16.150.100 on LAN to initiate any connection with MGMT01

Ensure your MGMT-TO-LAN firewall allows established traffic back.

join wks01 to your new domain (remember, it's always DNS) 

fw-mgmt:

```bash
set firewall name LAN-to-MGMT rule 20 action accept
set firewall name LAN-to-MGMT rule 20 destination address 172.16.200.11
set firewall name LAN-to-MGMT rule 20 source address 172.16.150.50-172.16.150.100 
configure
set firewall name MGMT-to-LAN rule 10 action accept
set firewall name MGMT-to-LAN rule 10 state established enable
commit
save
```

## Configure DNS on mgmt01

For networks deploying DNS to support Active Directory, directory-integrated primary zones are strongly recommended and provide the following benefits:

* **Multimaster update and enhanced security based on the capabilities of Active Directory.**   
  
  In a standard zone storage model, DNS updates are conducted based upon a single-master update model. In this model, a single authoritative DNS server for a zone is designated as the primary source for the zone.  
  
  This server maintains the master copy of the zone in a local file. With this model, the primary server for the zone represents a single fixed point of failure. If this server is not available, update requests from DNS clients are not processed for the zone.  
  
  With directory-integrated storage, dynamic updates to DNS are conducted based upon a multimaster update model.  
  
  In this model, any authoritative DNS server, such as a domain controller running a DNS server, is designated as a primary source for the zone. Because the master copy of the zone is maintained in the Active Directory database, which is fully replicated to all domain controllers, the zone can be updated by the DNS servers operating at any domain controller for the domain.  
  
  With the multimaster update model of Active Directory, any of the primary servers for the directory-integrated zone can process requests from DNS clients to update the zone as long as a domain controller is available and reachable on the network.  
  
  Also, when using directory-integrated zones, you can use access control list (ACL) editing to secure a dnsZone object container in the directory tree. This feature provides granulated access to either the zone or a specified RR in the zone.  
  
  For example, an ACL for a zone RR can be restricted so that dynamic updates are only allowed for a specified client computer or a secure group such as a domain administrators group. This security feature is not available with standard primary zones.  
  
  Note that when you change the zone type to be directory-integrated, the default for updating the zone changes to allow only secure updates. Also, while you may use ACLs on DNS-related Active Directory objects, ACLs may only be applied to the DNS client service.

* **Zones are replicated and synchronized to new domain controllers automatically whenever a new one is added to an Active Directory domain.**   
  
  Although DNS service can be selectively removed from a domain controller, directory-integrated zones are already stored at each domain controller, so zone storage and management is not an additional resource. Also, the methods used to synchronize directory-stored information offer performance improvement over standard zone update methods, which can potentially require transfer of the entire zone.

* **By integrating storage of your DNS zone databases in Active Directory, you can streamline database replication planning for your network.**   
  
  When your DNS namespace and Active Directory domains are stored and replicated separately, you need to plan and potentially administer each separately. For example, when using standard DNS zone storage and Active Directory together, you would need to design, implement, test, and maintain two different database replication topologies. For instance, one replication topology is needed for replicating directory data between domain controllers, and another topology would be needed for replicating zone databases between DNS servers.  
  
  This can create additional administrative complexity for planning and designing your network and allowing for its eventual growth. By integrating DNS storage, you unify storage management and replication issues for both DNS and Active Directory, merging and viewing them together as a single administrative entity.

* **Directory replication is faster and more efficient than standard DNS replication.**   
  
  Because Active Directory replication processing is performed on a per-property basis, only relevant changes are propagated. This allows less data to be used and submitted in updates for directory-stored zones.

Create Reverse Zones for LAN, MGMT and DMZ

Create A and PTR records for

web01 (DMZ)

fw01(lan interface)

fw-mgmt(mgmt interface)

mgmt01 (A record should already be there)

wks01(A record should already be created)

log01 (mgmt)

Step one- Open dns manager. 

Step 2- Go to forward lookup zones and right click on the named folder. Add A record. Step 3- Fill out the necessary details. Enable ptr record. 

Note- you don't have to be exact with the name, if you want to be able to fw01 from the name firewall, just name it firewall. The ip needs to be exact though. 

Step 4- Setup the reverse dns. You will have to open the record filed in step 3 and the original host record to check and uncheck the ptr record. This will create a ptr record easily.

## Joining wks01 to AD

On wks01:

```erlang
Step 1- Change the DNS to the server
Step 2- Make sure the name is changed here- control panel/system and security/ system/ system properties/ computer name & domain changes. 
Step 3- Add to the domain. NOT WORKGROUP 
Step 4- Restart and eat a cake.
```

On Log01:

```bash
nmtui
* edit a connection
* ens192
change the DNS server 172.16.200.11
```

## Windows Event Logs->GrayLog

#### Beats Input

Some of you are familiar with filebeat and winlogbeat from internships or other classes. We will use this same software here to forward windows security events generated on mgmt01 to Graylog. Observe and duplicate the new input feed below. Don't forget to allow 5044/tcp through log01's host based firewall

On Mgmt from chrom go to the web panel for graylog and add a new input called Beats. The input should be named winlogbeats . 

### Sidecar

Sidecar is a windows agent that will run on mgmt. It communicates with graylog over the winlogbeat input you just created. It authenticates with an API token that you will need to generate.

Mgmt01: Chrome URL: log01-nilesh:9000/system/sidecars

Create a token and save it to notepad

Open powershell as administrator

```
mkdir C:\SEC350
cd C:\SEC350
wget https://github.com/Graylog2/collector-sidecar/releases/download/1.1.0/graylog_sidecar_installer_1.1.0-1.exe -o sidecar.exe
./sidecar.exe /S -SERVERURL=http://log01-nilesh:9000/api -APITOKEN=yourapitoken
###Registering and Starting the Service
cd 'C:\Program Files\Graylog\sidecar\'
./graylog-sidecar.exe -service install
./graylog-sidecar.exe -service start
```

On the command line you can provide a path to the configuration file with the `-c`switch.The default configuration path on Linux systems is `/etc/graylog/sidecar/sidecar.yml`and `C:\Program Files\Graylog\sidecar\sidecar.yml`on Windows.  


Most configuration parameters come with built-in defaults.The only parameters that need adjustment are `server_url`and `server_api_token`.You can get your API token by following the link on the Sidecars Overview page

### Sidecar configuration

### SIDECAR.YML REFERENCE

| Parameter                         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| server_url                        | URL to the Graylog API, e.g. `http://192.168.1.1:9000/api/`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| server_api_token                  | The API token to use to authenticate against the Graylog server API.<br>e.g `1jq26cssvc6rj4qac4bt9oeeh0p4vt5u5kal9jocl1g9mdi4og3n`<br>The token is mandatory and needs to be configured.                                                                                                                                                                                                                                                                                                                                                             |
| node_id                           | The node ID of the sidecar. This can be a path to a file or an ID string.<br>Example file path: `file:/etc/graylog/sidecar/node-id`<br>Example ID string: `6033137e-d56b-47fc-9762-cd699c11a5a9`<br>ATTENTION: Every sidecar instance needs a unique ID!<br>Default: `file:/etc/graylog/sidecar/node-id`                                                                                                                                                                                                                                             |
| node_name                         | Name of the Sidecar instance, will also show up in the web interface.<br>The hostname will be used if not set.                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| update_interval                   | The interval in seconds the sidecar will fetch new configurations from the Graylog server<br>Default: `10`                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| tls_skip_verify                   | This configures if the sidecar should skip the verification of TLS connections. Default: `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| send_status                       | This controls the transmission of detailed sidecar information like collector status,<br>metrics and log file lists. It can be disabled to reduce load on the Graylog server if needed.<br>Default: `true`                                                                                                                                                                                                                                                                                                                                           |
| list_log_files                    | Send a directory listing to Graylog and display it on the host status page,<br>e.g. `/var/log`. This can also be a list of directories. Default: `[]`                                                                                                                                                                                                                                                                                                                                                                                                |
| cache_path                        | The directory where the sidecar stores internal data. Default: `/var/cache/graylog-sidecar`                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| collector_configuration_directory | The directory where the sidecar generates configurations for collectors.<br>Default: `/var/lib/graylog-sidecar/generated`                                                                                                                                                                                                                                                                                                                                                                                                                            |
| log_path                          | The directory where the sidecar stores its logs. Default: `/var/log/graylog-sidecar`                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| log_rotate_max_file_size          | The maximum size of the log file before it gets rotated. Default: `10MiB`                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| log_rotate_keep_files             | The maximum number of old log files to retain.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| collector_binaries_accesslist     | A list of binaries which are allowed to be executed by the Sidecar.<br>An empty list disables the white list feature.<br>Default:`/usr/bin/filebeat, /usr/bin/packetbeat, /usr/bin/metricbeat, /usr/bin/heartbeat,`<br>`/usr/bin/auditbeat, /usr/bin/journalbeat, /usr/share/filebeat/bin/filebeat,`<br>`/usr/share/packetbeat/bin/packetbeat, /usr/share/metricbeat/bin/metricbeat,`<br>`/usr/share/heartbeat/bin/heartbeat, /usr/share/auditbeat/bin/auditbeat,`<br>`/usr/share/journalbeat/bin/journalbeat, /usr/bin/nxlog, /opt/nxlog/bin/nxlog` |



log01:

```bash
#need to restart firewall for log01
sudo firewall-cmd --zone=public --add-port=5044/tcp --permanent
sudo firewall-cmd --reload
```

# Reflections

This lab was relatively easier to understand and follow. We never used powershell in our SYS265 and SYS255 class to setup a windows AD so I just had to use the GUI to setup the AD. Now that I think about it, I have yet to come accross a good logging tool that does not break often or has simple instructions. I think data flow diagrams can really help in understanding the flow of logs and firewalls.
