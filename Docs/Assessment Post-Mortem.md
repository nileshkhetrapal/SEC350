# Assessment Post-Mortem

## Things that worked well

Netplan configs worked flawlessly

Installation of system services like nginx and DHCP

System configurations

Firewall configs worked well

User configurations worked well

## Things that did not work well

### Firewall zones still confused me

I had to delete them to get certain screenshots and then re-enable them to get the other screenshots.

### Script transfer

Script transfer had to be done via the copy paste feature on VMWare workstation. This is not a very nice method of doing this since it is not a feature that I can work with in production nor does it work reliably. 

### Rsyslog config was not tested correctly.

The test created for checking whether or not the script was working had the user check the output of the program to verify if the sec350.conf was generated correctly or not. A user input error in the early stages of development of the script mispelled RSYSLOG for RYSYLOG . Because the verification was done by a Human, the mispelled configuration file was not fixed until after multiple layers of troubleshooting.

##### Troubleshooting for Rsyslog was not done correctly

I have learnt multiple times that Human input error are natural and failing to plan for them is failing to plan. I should have retyped the rsyslog config manually earlier in the troubleshooting cycle than I did. I blamed the issue on the firewall and kept on messing around with edge01 to get it to work. I should have had more trust in my firewall configs than the Rsyslog configs. 

### How I will improve my workflow

I will create better unit tests for the development of scripts. Maybe even have troubleshooting built in to the scripts to account for basic issues like needing to restart certain services after a configuration change.

Some of my plans for fixing the script transfer issue include setting up a small web server to act as a remote script server to serve scripts to all the machines with internet connection. But that still leaves me with the issue of having to connect the machines to the internet manually. Another solution could be to convert a jump box into a script server that can exclusively talk to the main script server hosted on my personal computer.




