# Standardising log timestamps accross different machines

By default the logging systems will use different timestamps. This causes a problem because there are use cases where the computers aren't even on the same time zone.

## RW01 *XUbuntu*

#### Checking how bad the problem is

```bash
date
logger -t test whattimeisit
sudo cat /var/log/syslog | grep whattimeisit
```

#### Fixing it (somewhat)

goto /etc/rsyslog.conf and uncomment the following line out:

```yml
$ActionFileDefaultTemplate RSYSLOG_Traditional_FileFormat
```


