#!/bin/bash

# update kernal for centos 7
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
# yum --enablerepo=elrepo-kernel install kernel-ml -y
# grub2-set-default 0 && shutdown -r now

enable bbr
wget https://raw.githubusercontent.com/bannedbook/fanqiang/master/v2ss/server-cfg/sysctl.conf -O -> /etc/sysctl.conf
sysctl -p

# install binary
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
echo 'v2ray installed!'

# generate config file /usr/local/etc/v2ray/config.json
uid=`uuidgen`

cat << EOF > /usr/local/etc/v2ray/config.json
{
  "log": {
    "loglevel": "warning",
    "access": "/dev/null",
    "error": "/dev/null"
  },
  "inbounds": [{
    "port": 80,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$uid",
          "level": 1,
          "alterId": 0
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/asdfghjkl"
      }
    }
  }],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "allowed"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF


echo 'config generated to /usr/local/etc/v2ray/config.json'

# add port to firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# close firewall
# systemctl stop firewalld.service
# systemctl disable firewalld.service
# service iptables stop
# chkconfig iptables off

yum install -y chrony
timedatectl set-timezone Asia/Shanghai

# start v2ray
systemctl start v2ray && systemctl status v2ray
