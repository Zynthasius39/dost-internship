nodes:
  - name: k8s-eclair-1
    ip: 10.0.16.11
    mac: "52:54:00:0a:10:0b"
    memory: 4096
    vcpu: 2
    role: master

  - name: k8s-eclair-2
    ip: 10.0.16.12
    mac: "52:54:00:0a:10:0c"
    memory: 8192
    vcpu: 4
    role: worker

  - name: k8s-eclair-3
    ip: 10.0.16.13
    mac: "52:54:00:0a:10:0d"
    memory: 8192
    vcpu: 4
    role: worker
 
cidr: /24
gateway: 10.0.16.1
nameservers:
  search:
    - alak
  addresses:
    - 10.0.16.1

os_name: debian13
vol_capacity: 10
base_image: /home/qemu/images/debian-13-genericcloud-amd64.qcow2

ssh_public_key: "{{ 'keys/k8s-eclair.pub' | realpath }}"
ssh_private_key: "{{ 'keys/k8s-eclair.key' | realpath }}"
