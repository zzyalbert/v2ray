#!/bin/bash

# enable bbr
wget https://raw.githubusercontent.com/bannedbook/fanqiang/master/v2ss/server-cfg/sysctl.conf -O -> /etc/sysctl.conf
sysctl -p
echo 'enable bbr'

# add port to firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
echo 'permit 80/443 to firewall'

# disable selinux
setenforce 0

# install nginx
yum install -y nginx

# generate config file /etc/nginx/nginx.conf
cat << EOF > /etc/nginx/nginx.conf
user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

    # Settings for a TLS enabled server.

    server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        ssl_certificate "/usr/local/etc/v2ray/v2ray.pem";
        ssl_certificate_key "/usr/local/etc/v2ray/v2ray.key";
        ssl_protocols         TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers           HIGH:!aNULL:!MD5;
        ssl_session_cache shared:MozSSL:10m;
        ssl_prefer_server_ciphers off;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        location /asdfghjkl { # V2Ray websocket path
            proxy_redirect off;
            proxy_pass http://127.0.0.1:8080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;

            # Show realip in v2ray access.log
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

}
EOF

# install v2ray
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
echo 'v2ray installed!'

# mv resource
mv crt/* /usr/local/etc/v2ray/
mv html/* /usr/share/nginx/html/

# generate config file /usr/local/etc/v2ray/config.json
uid=`uuidgen`

cat << EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [{
    "port": 8080,
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
systemctl enable nginx && systemctl start nginx
systemctl start v2ray && systemctl status v2ray
