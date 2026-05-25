#!/bin/sh

BASEDIR="$(pwd)/keys"
KEYNAME=vm-sshkey
SUFFIX="$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)"
KEYPATH="$BASEDIR/${KEYNAME}_$SUFFIX"

mkdir -vp "$BASEDIR"

ssh-keygen \
  -t ed25519 \
  -N '' \
  -f "$KEYPATH"

# mikefarah/yq 4.52.4
yq ".ssh_authorized_keys = [\"$(<$KEYPATH.pub) ${KEYNAME}_$SUFFIX\"]" user-data.tpl > user-data
