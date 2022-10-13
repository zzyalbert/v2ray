#!/bin/bash

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

echo 'config generated to /usr/local/etc/v2ray/config.json'

# add port to firewall
firewall-cmd --zone=public --add-port=9200/tcp --permanent
firewall-cmd --reload

# start v2ray
systemctl start v2ray && systemctl status v2ray
