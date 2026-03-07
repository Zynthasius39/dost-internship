#cloud-config
allow_public_ssh_keys: true
disable_root: true
disable_root_opts: no-port-forwarding,no-agent-forwarding,no-X11-forwarding
package_update: true
packages:
  - ansible
ssh_deletekeys: true
ssh_genkeytypes:
  - rsa
  - ecdsa
  - ed25519
ssh_publish_hostkeys:
  blacklist:
    - rsa
  enabled: true
ssh_quiet_keygen: true
