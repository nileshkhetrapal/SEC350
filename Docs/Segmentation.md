# Segmentation

## Workstation01

#### Adding a new admin

Go to search and type in user. Click on what comes up and select add other users to this pc. 

Once created, select change account type and select administrator.

In the About menu, you should see the name of your computer next to **PC name** and a button that says **Rename PC**. Click this button.

#### Networking on windows lmao

Go to the network and sharing center in the control panel. Double click on the connection interface. From there click on properties. Scroll to IPv4 settings and open them.

IP Address:  172.16.150.50

Netmask:  255.255.255.0

Gateway:  172.16.150.2

DNS:  172.16.150.2

If you are using a VM make sure to update the interface.

### Vyos configuration

Source NAT is typically referred to simply as NAT. To be more correct, what most people refer to as NAT is actually the process of **Port Address Translation (PAT)**, or **NAT Overload**. The process of having many internal host systems communicate to the Internet using a single or subset of IP addresses.

To setup SNAT, we need to know:

- The internal IP addresses we want to translate;
- The outgoing interface to perform the translation on;
- The external IP address to translate to.

```python
configure
set nat source rule 15 description "NAT FROM DMZ to LAN"
set nat source rule 15 outbound-interface eth0
set nat source rule 15 source address 172.16.150.0/24
set nat source rule 15 translation address masquerade
commit
save
```

As usual, make sure the commands are actually committed and saved. 

##### DNS forwarding on VYOS

```python
set service DNS forwarding listen-address 172.16.150.2
set service DNS forwarding allow-from 172.16.150.0/24
commit
save
```






