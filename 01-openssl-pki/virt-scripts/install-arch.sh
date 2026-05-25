#!/bin/sh

source "$(pwd)/common.sh"

addVM

# Install a VM
virt-install \
   --connect qemu:///system \
   --name "$CODENAME-arch-$(<"$CNTFILE")" \
   --vcpus 2 \
   --memory 2048 \
   --noreboot \
   --os-variant detect=off,name=archlinux \
   --disk=size=10,backing_store="$ISOPATH/Arch-Linux-x86_64-cloudimg-20260215.491172.qcow2" \
   --cloud-init user-data="$(pwd)/user-data,meta-data=$(pwd)/meta-data,network-config=$(pwd)/network-config" \
   || removeVM  # Rollback the counter if failed
