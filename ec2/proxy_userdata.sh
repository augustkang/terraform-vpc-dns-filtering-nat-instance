#!/bin/bash
set -x

sudo yum update -y
sudo yum install -y perl gcc autoconf automake make sudo wget gcc-c++ libxml2-devel libcap-devel libtool libtool-ltdl-devel openssl openssl-devel squid

sudo mkdir /etc/squid/ssl
cd /etc/squid/ssl
sudo openssl genrsa -out squid.key 2048
sudo openssl req -new -key squid.key -out squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
sudo openssl x509 -req -days 3650 -in squid.csr -signkey squid.key -out squid.crt
sudo cat squid.key squid.crt | sudo tee squid.pem

cat | sudo tee /etc/squid/squid.conf <<EOF
visible_hostname squid

http_port 3129 intercept
acl 80_port port 80
acl allowed_http_sites dstdomain .google.com
http_access deny allowed_http_sites 80_port
deny_info 301:https://%H%R allowed_http_sites

https_port 3130 cert=/etc/squid/ssl/squid.pem ssl-bump intercept
acl 443_port port 443
http_access allow 443_port
acl allowed_https_sites ssl::server_name .google.com
acl step1 at_step SslBump1
acl step2 at_step SslBump2
acl step3 at_step SslBump3
ssl_bump peek step1 all
ssl_bump peek step2 allowed_https_sites
ssl_bump splice step3 allowed_https_sites
ssl_bump terminate step2 all

http_access deny all
EOF

sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130
sudo iptables-save > /etc/sysconfig/iptables
sudo systemctl start squid
