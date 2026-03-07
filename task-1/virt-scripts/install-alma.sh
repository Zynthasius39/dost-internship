#!/bin/sh

source "$(pwd)/common.sh"

addVM

# Install a VM
virt-install \
   --connect qemu:///system \
   --name "$CODENAME-alma-$(<"$CNTFILE")" \
   --vcpus 2 \
   --memory 2048 \
   --noreboot \
   --os-variant detect=off,name=almalinux10 \
   --disk=size=10,backing_store="$ISOPATH/AlmaLinux-10-GenericCloud-10.1-20251125.0.x86_64.qcow2" \
   --cloud-init user-data="$(pwd)/user-data,meta-data=$(pwd)/meta-data,network-config=$(pwd)/network-config" \
   || removeVM  # Rollback the counter if failed
