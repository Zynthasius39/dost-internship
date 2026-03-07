#!/bin/sh

HAP_CA_DOMAIN=ca.dost.edu.az
HAP_VIP_DOMAIN=ha.dost.edu.az
for C in 1 2; do
  HAP_DOMAIN=ha$C.dost.edu.az
  cat haproxy/haproxy.cfg.tpl | \
    sed \
      -e "s/__HAP_CA_DOMAIN__/$HAP_CA_DOMAIN/g" \
      -e "s/__HAP_VIP_DOMAIN__/$HAP_VIP_DOMAIN/g" \
      -e "s/__HAP_DOMAIN__/$HAP_DOMAIN/g" | \
    ssh haproxy-$C "sudo tee /etc/haproxy/haproxy.cfg && sudo sudo systemctl reload haproxy" >/dev/null
done
