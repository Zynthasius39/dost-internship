global
  maxconn 20000
  log stdout format raw local0 debug
  user haproxy
  group haproxy
  stats socket /run/haproxy/admin.sock mode 660 level admin
  stats timeout 30s

  # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
  ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
  ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
  ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
  log global
  mode http
  option httplog
  option dontlognull
  timeout connect 5000
  timeout client  50000
  timeout server  50000

userlist dostlar
  user joe     insecure-password joespassword
  user richard password          $6$6PwCRmIvUBNQ6dcf$43EhoVB5/ODUU.wDMFYDhesYWMRnIy6OT8BPhTR5pGw0R5WBk47YBjr27z7GnU/EFOLDtgpPv5EdELE1cJ3wY/

frontend http-in
  bind *:80
  mode http

  acl path_health path_beg /health
  http-request return status 200 content-type "text/plain" string "OK" if path_health

  acl host_ca hdr(host) -i __HAP_CA_DOMAIN__
  http-request redirect scheme https code 301 unless host_ca

  default_backend ca-backend

frontend https-in
  # mTLS
  bind *:443 ssl crt /etc/haproxy/certs/ ca-file /etc/haproxy/ca-chain.crt verify required crl-file /etc/haproxy/crl-chain.crl

  # bind *:443 ssl crt /etc/haproxy/certs/

  acl valid_host hdr(host) -i __HAP_VIP_DOMAIN__
  http-request deny deny_status 421 unless valid_host

  acl path_api path_beg /api
  use_backend api-backend if path_api

  default_backend web-backend

backend web-backend
  mode http
  balance roundrobin
  server web1 127.0.0.1:8080 check
  server web2 127.0.0.1:8081 check

backend api-backend
  mode http
  balance leastconn
  server api1 127.0.0.1:3000 check
  server api2 127.0.0.1:3001 check

backend ca-backend
  mode http
  server cas1 127.0.0.1:8000 check
