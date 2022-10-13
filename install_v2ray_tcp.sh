#!/bin/bash

# update kernal for centos 7
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
# yum --enablerepo=elrepo-kernel install kernel-ml -y
# grub2-set-default 0 && shutdown -r now

# enable bbr
# wget https://raw.githubusercontent.com/bannedbook/fanqiang/master/v2ss/server-cfg/sysctl.conf -O -> /etc/sysctl.conf
# sysctl -p

# install binary
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
echo 'v2ray installed!'

# generate config file /usr/local/etc/v2ray/config.json
cat << EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [{
    "port": 25250,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "bdb6335c-09cb-44c9-8d75-ccb4b5625af2",
          "alterId": 0
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

if [[ $type == 'shadowsocks' ]];then
    cat << EOF > /usr/local/etc/v2ray/config.json
{
  "log": {
    "loglevel": "warning",
    "access": "/dev/null",
    "error": "/dev/null"
  },
  "inbounds": [
    {
      "port": 30303,
      "protocol": "shadowsocks",
      "settings": {
        "method": "aes-256-gcm",
        "password": "ac24f751-77e1-4f8c-b894-7c9b0d3fbba1",
        "network": "tcp,udp",
        "level": 0
      }
    }
  ],
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
        "domain": [
          "google.com",
          "apple.com",
          "oppomobile.com"
        ],
        "type": "field",
        "outboundTag": "allowed"
      },
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

fi

echo 'config generated to /usr/local/etc/v2ray/config.json'

# add port to firewall
firewall-cmd --zone=public --add-port=9200/tcp --permanent
firewall-cmd --reload

# start v2ray
systemctl start v2ray && systemctl status v2ray
