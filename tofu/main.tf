locals {
  sshkey          = file(var.pub_key)
  num_k3s_masters = length(var.master_ips)
  num_k3s_workers = length(var.worker_ips)
}

resource "proxmox_virtual_environment_vm" "proxmox_vm_master" {
  count     = local.num_k3s_masters
  name      = "${var.deployment_name}-k3s-master${count.index + 1}"
  node_name = var.pm_node_name
  pool_id   = var.pool_id
  tags      = var.tags

  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }
  cpu {
    cores = var.cpu_cores
  }
  memory {
    dedicated = var.num_k3s_masters_mem
  }
  disk {
    datastore_id = var.datastore
    interface    = var.disk_interface
    discard      = var.disk_discard
    size         = var.disk_size
    ssd          = var.disk_ssd
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.master_ips[count.index]}/${var.networkrange}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [local.sshkey]
      password = var.vm_user_password
      username = var.host_user
    }

  }
  network_device {
    bridge = var.net_bridge
  }
}

resource "proxmox_virtual_environment_vm" "proxmox_vm_workers" {
  count     = local.num_k3s_workers
  name      = "${var.deployment_name}-k3s-worker${count.index + 1}"
  node_name = var.pm_node_name
  pool_id   = var.pool_id
  tags      = var.tags

  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }
  cpu {
    cores = var.cpu_cores
  }
  memory {
    dedicated = var.num_k3s_workers_mem
  }
  disk {
    datastore_id = var.datastore
    interface    = var.disk_interface
    discard      = var.disk_discard
    size         = var.disk_size
    ssd          = var.disk_ssd
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/${var.networkrange}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [local.sshkey]
      password = var.vm_user_password
      username = var.host_user
    }

  }
  network_device {
    bridge = var.net_bridge
  }
}

resource "local_file" "k8s_file" {
  content = templatefile("./templates/k8s.tpl", {
    k3s_master_ips = [
      for instance in proxmox_virtual_environment_vm.proxmox_vm_master : {
        ip      = instance.ipv4_addresses[1][0]
        ssh_key = var.pvt_key
      }
    ]
    k3s_worker_ips = [
      for instance in proxmox_virtual_environment_vm.proxmox_vm_workers : {
        ip      = instance.ipv4_addresses[1][0]
        ssh_key = var.pvt_key
      }
    ]
  })
  filename = "../ansible/inventory/${var.deployment_name}/hosts.ini"
}
