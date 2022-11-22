#!/bin/bash

# enable bbr
wget https://raw.githubusercontent.com/bannedbook/fanqiang/master/v2ss/server-cfg/sysctl.conf -O -> /etc/sysctl.conf
sysctl -p
echo 'enable bbr'

# add port to firewall
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
echo 'permit 443 to firewall'

# install v2ray
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
echo 'v2ray installed!'

# mv crt
mv crt/* /usr/local/etc/v2ray/

# generate config file /usr/local/etc/v2ray/config.json
uid=`uuidgen`

cat << EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [{
    "port": 443,
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
      },
      "security": "tls",
      "tlsSettings": {
        "certificates": [
          {
            "certificateFile": "/usr/local/etc/v2ray/v2ray.pem",
            "keyFile": "/usr/local/etc/v2ray/v2ray.key"
          }
        ]
      }
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

echo 'config generated to /usr/local/etc/v2ray/config.json'

# start
systemctl start v2ray && systemctl status v2ray
