# Syslog Organisation on Log01

## Vyos

It is imperative that you change your default password before turning on SSH.

```bash
configure
set system login user vyos authentication plaintext-password password
commit
save
exit
```

Enable SSH:

```vyos
configure
set service ssh listen-address 10.0.17.120
commit
save
exit
```

Add an Admin:

```roboconf
configure
set system login user sarah authentication plaintext-password password
commit
save
```

Set syslog host:

```bro
configure
set system syslog host 172.16.50.5 facility authpriv level info
commit
save
exit
```

## SSH keypair on RW01

Establishing an SSH (Secure Shell) connection is essential to log in and effectively manage a remote server. Encrypted keys are a set of access credentials used to establish a secure connection.

```bash
mkdir –p $HOME/.ssh
chmod 0700 $HOME/.ssh
ssh-keygen
```

/.ssh/id_rsa should have the created key file.

You now need to use scp to send the file to the Vyos machine. `ssh-copy-id` does not work with vyos.

```bash
scp -i /home/nilesh/.ssh/id_rsa.pub nile@10.0.17.120:/home/config/auth
```

```bash
scp remoteuser@remoteserver:/remote/folder/remotefile.txt  localfile.txt
```

Disable password authentication

```bash
sudo nano /etc/ssh/sshd_config
```

Search the file and find the PasswordAuthentication option. Edit the file and change the value to no.

```bash
sudo systemctl restart ssh
```

---

# Log organisation

We will use an already prepared set of rules for our logs. on Log01

```bash
sudo -i
nano /etc/rsyslog.conf
#Uncomment 4 lines: 2 under Provides UDP syslog reception and 2 under UDP syslog reception
cd /etc/rsyslog.d/
wget https://raw.githubusercontent.com/gmcyber/sec350-share/main/03-sec350.conf
cat 03-sec350.conf
systemctl restart rsyslog
```

Send test logs from web01 to log01:

```bash
logger -t SEC350 Testing web01->log01 cystom rsyslog configuration
```

To view the logs on Log01:

```bash
ls -lR --color /var/log/remote-syslog/
```

Add 

```
authpriv.* @172.16.50.5
```

to `/etc/rsyslog.d/sec350.conf`
