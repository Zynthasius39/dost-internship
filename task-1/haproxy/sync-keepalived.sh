#!/bin/sh

declare -A NODE_1=([if]="eth0" [state]="MASTER" [priority]="100")
declare -A NODE_2=([if]="enp1s0" [state]="BACKUP" [priority]="95")

for C in 1 2; do
  declare -n NODE=NODE_$C
  cat haproxy/keepalived.conf.tpl | \
    sed \
      -e "s/__KA_IF__/${NODE[if]}/g" \
      -e "s/__KA_STATE__/${NODE[state]}/g" \
      -e "s/__KA_PRIORITY__/${NODE[priority]}/g" | \
    ssh haproxy-$C "sudo tee /etc/keepalived/keepalived.conf && sudo sudo systemctl reload keepalived" >/dev/null
done
