- Enable BBR (optional)

add the following to /etc/sysctl.conf

```bash
fs.file-max=65535
net.ipv6.conf.all.accept_ra=2
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
```
run command
```bash
sysctl -p
```

- Add CDN support

register a domain name and add to CDN(like www.cloudflare.com)

- Enable nginx

install
```bash
yum install -y nginx
```

edit `/etc/nginx/nginx.conf` and check config
```bash
nginx -t
```

start it
```bash
nginx
```
or reload config
```bash
nginx -s reload
```

- Install CA

install CA tools
```
curl https://get.acme.sh | sh

source ~/.bashrc

yum install -y netcat socat

```

Generate & Install
```
sudo ~/.acme.sh/acme.sh --register-account -m zzyalbert@gmail.com --force

sudo ~/.acme.sh/acme.sh --issue -d v1.btcfun.top --standalone -k ec-256 --force

sudo ~/.acme.sh/acme.sh --installcert -d v1.btcfun.top --fullchainpath /usr/local/etc/v2ray/v2ray.crt --keypath /usr/local/etc/v2ray/v2ray.key --ecc --force

```

Update CA Manually
```
sudo ~/.acme.sh/acme.sh --renew -d v1.btcfun.top --force --ecc
```

- Download
```bash
wget https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
```

- Install
```bash
bash install-release.sh
```

- Compatible with old clients(MD5 authentication)
Open /etc/systemd/system/v2ray.service, add the following line in the `[Service]` block

```
Environment="V2RAY_VMESS_AEAD_FORCED=false"
```

Reload systemd and restart v2ray

```
systemctl daemon-reload
systemctl restart v2ray
```

- Edit config.json in /usr/local/etc/v2ray/config.json
use the following command to generate UUID
```
cat /proc/sys/kernel/random/uuid
```

- Enable NTP
```bash
yum install -y chrony
timedatectl set-timezone Asia/Shanghai
systemctl start chrony
systemctl enable chrony
```

- Close firewall
```bash
systemctl stop firewalld.service
systemctl disable firewalld.service
service iptables stop
chkconfig iptables off
```

- Start v2ray
```bash
systemctl start v2ray
```
