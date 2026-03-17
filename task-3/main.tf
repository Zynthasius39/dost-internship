terraform {
  required_version = "~> 1.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  nodes = {
    "k8s-eclair-0" = { ip = "10.0.16.11/20", mac = "52:54:00:0a:10:0b", memory = 4096, vcpu = 2, role = "master" }
    "k8s-eclair-1" = { ip = "10.0.16.12/20", mac = "52:54:00:0a:10:0c", memory = 8192, vcpu = 4, role = "worker" }
    "k8s-eclair-2" = { ip = "10.0.16.13/20", mac = "52:54:00:0a:10:0d", memory = 8192, vcpu = 4, role = "worker" }
  }
}

resource "tls_private_key" "node" {
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  filename        = "${path.module}/k8s-eclair.pem"
  content         = tls_private_key.node.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_key" {
  filename = "${path.module}/k8s-eclair.pub"
  content  = tls_private_key.node.public_key_openssh
}

resource "libvirt_volume" "node" {
  for_each = local.nodes
  name     = "${each.key}.qcow2"
  pool     = "main"
  capacity = 10737418240  # 10GB
  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path   = "/home/qemu/images/debian-13-genericcloud-amd64.qcow2"
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "init" {
  for_each = local.nodes
  name     = "${each.key}-init"

  meta_data = yamlencode({
    instance-id    = each.key
    local-hostname = each.key
  })

  user_data = templatefile("${path.module}/cloud-init.tftpl", {
    hostname    = each.key
    ssh_pub_key = [tls_private_key.node.public_key_openssh]
  })

  network_config = templatefile("${path.module}/network-config.tftpl", {
    ip          = [each.value.ip]
    mac         = each.value.mac
    gateway     = "10.0.16.1"
    search      = ["alak"]
    dns_servers = ["10.0.16.1"]
  })
}

resource "libvirt_volume" "cloudinit" {
  for_each = local.nodes
  name     = "${each.key}-cloudinit.iso"
  pool     = "cloudinit"

  create = {
    content = {
      url = libvirt_cloudinit_disk.init[each.key].path
    }
  }
}

resource "libvirt_domain" "node" {
  for_each    = local.nodes
  name		    = each.key
  memory	    = each.value.memory
  memory_unit = "MiB"
  vcpu		    = each.value.vcpu
  autostart   = true
  running     = true
  type        = "kvm"

  os = {
    type         = "hvm"
    type_machine = "q35"
  }

  features = {
    acpi = true
    apic = {
      eoi = "on"
    }
    vm_port = {
      state = "off"
    }
  }

  cpu = {
    mode = "host-passthrough"
  }

  clock = {
    timer = [
      {
        name        = "rtc"
        tick_policy = "catchup"
      },
      {
        name        = "pit"
        tick_policy = "delay"
      },
      {
        name    = "hpet"
        present = "no"
      }
    ]
  }


  devices = {
    disks = [
      {
        driver = {
          type = "qcow2"
        }
        source = {
          file = {
            file = libvirt_volume.node[each.key].path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        driver = {
          type = "raw"
        }
        source = {
          file = {
            file = libvirt_volume.cloudinit[each.key].path
          }
        }
        target = {
          dev = "vdb"
          bus = "virtio"
        }
      }
    ]

    interfaces = [
      {
        mac = {
          address = each.value.mac
        }
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "ovs.20"
          }
        }
      }
    ]
  }
}
