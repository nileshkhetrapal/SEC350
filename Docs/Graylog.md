# GrayLog Setup wiki

Graylog is basically another version of ELK stack. It is far inferior in built in tools but makes up for it through its massive plugin library and developer friendly presets.

It can take data from different rsyslog clients, put filters on it and present it to us through a web interface. 

## Installing GrayLog

Make sure that this is being installed on Log01. This has to be installed on the main system that is collecting logs. The guide is built for a gui-less Centos 7 .

### Installing Java

The application is actually built on Java. Make sure that the version you are using is the latest one.

`sudo yum install java-11-openjdk-headless.x86_64`



### Installing MongoDB

Graylog uses MongoDB as its database. MongoDB is a solid mid-tier database structure but it works really optimally for logs.



To install MongoDB we will have to add the repository file in `/etc/yum.repos.d/mongodb-org.repo` with the following contents:

```yml
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
```

After that, install the latest release of MongoDB with 

`sudo yum install mongodb-org.`

Now all we have to do is make sure MongoDB is started every time we boot the system.

```bash
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl start mongod.service
sudo systemctl --type=service --state=active | grep mongod
```

The last command makes sure that MongoDB is setup correctly and is running.

### Installing Elasticsearch

This setup of Graylog uses elasticsearch for searching through the logs.

First install the Elastic GPG key with `rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch` then add the repository file `/etc/yum.repos.d/elasticsearch.repo` with the following contents:

```yml
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Run this command to install elasticsearch

`sudo yum install elasticsearch-oss.`

Modify the [Elasticsearch configuration file](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/settings.html#settings) (`/etc/elasticsearch/elasticsearch.yml`) and set the cluster name to `graylog` and uncomment `action.auto_create_index: false` to enable the action:

```bash
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT
```

We then do the same thing for Elasticsearch as we did for MongoDB

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch
```

---

### Download, install and setup

Now we can proceed to installing Graylog.

install the Graylog repository configuration and Graylog itself with the following commands:

```bash
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.rpm
sudo yum install graylog-server graylog-enterprise-plugins graylog-integrations-plugins
```

#### Edit the Configuration File

Before we can edit the server.conf file we need to generate a sha256sum of a string that will act as our admin password. Use this command to easily make one :

```bash
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
```

Read the instructions within the configurations file and edit as needed, located at `/etc/graylog/server/server.conf`. Additionally add `password_secret` (there is apparently a minimum character limit for this so it cannot be a single word, probably designed for a sentence) and `root_password_sha2` as these are mandatory and **Graylog will not start without them**.

To be able to connect to Graylog you should set `http_bind_address` to the public host name or a public IP address of the machine you can connect to.

#### Firewall

```bash
sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
sudo firewall-cmd --reload
```

#### Enable Graylog on startup

```bash
sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl --type=service --state=active | grep graylog
```

### SELINUX INFORMATION

I assume that you have `policycoreutils-python` installed to manage SELinux.

If you’re using SELinux on your system, you need to take care of the following settings:

* Allow the web server to access the network: `sudo setsebool -P httpd_can_network_connect 1`
* If the policy above does not comply with your security policy, you can also allow access to each port individually:
  * Graylog REST API and web interface: `sudo semanage port -a -t http_port_t -p tcp 9000`
  * Elasticsearch (only if the HTTP API is being used): `sudo semanage port -a -t http_port_t -p tcp 9200`
* Allow using MongoDB’s default port (27017/tcp): `sudo semanage port -a -t mongod_port_t -p tcp 27017`

## Web interface time

On RW01, or any machine with a web browser, go to http://log01:9000

The default login is admin with the password you created earlier.

The first thing we need to do to setup Graylog to work as syslog server. 

Go to http://log01:9000/system/inputs

* [ ] Go to drop down menu for select inputs
* [ ] Select syslog-udp
* [ ] select launch input
  
  -- = stuff that remained the same
* [ ] Title: syslog-udp
* [ ] --Allow override date: true
* [ ] --bind address: 0.0.0.0
* [ ] --expand structured data: false
* [ ] --number worker threads: 2
* [ ] --override source:
* [ ] Port: 1541
* [ ] --recv buffer size: 262144
* [ ] Store full message: true
  
  save

on Log01:

```bash
sudo firewall-cmd --zone=public --add-port=1514/udp --permanent
sudo firewall-cmd --reload
```

#### Updating web01 to join the new party

The first thing to do on web01 is to update the sec350.conf file.

```roboconf
user.notice @172.16.50.5:1514
authpriv.* @172.16.50.5:1514
```

Now just restart rsyslog on web01.

```bash
sudo systemctl restart rsyslog
```

### Complete

Now create some test data on web01 and see if the logs are showing up through the web interface.
