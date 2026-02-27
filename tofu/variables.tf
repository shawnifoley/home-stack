variable "pm_user" {
  description = "The username for the proxmox user"
  type        = string
  sensitive   = false
  default     = "root@pam"

}
variable "pm_api_password" {
  description = "The password for the proxmox API user"
  type        = string
  sensitive   = true
}

variable "vm_user_password" {
  description = "Optional password for the VM host user. Prefer SSH keys."
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = false
}

variable "pm_host" {
  description = "The hostname or IP of the proxmox server"
  type        = string
}

variable "pm_node_name" {
  description = "name of the proxmox node to create the VMs on"
  type        = string
  default     = "pve"
}

variable "host_user" {
  description = "The username for the host user"
  type        = string
}

variable "deployment_name" {
  description = "Deployment/environment name used for VM naming and inventory output (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "pvt_key" {
  description = "Path to the private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "pub_key" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "num_k3s_masters_mem" {
  type    = number
  default = 4096
}

variable "num_k3s_workers_mem" {
  type    = number
  default = 4096
}

variable "template_id" {
  type    = number
  default = 1002
}
variable "pool_id" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "master_ips" {
  type        = list(string)
  description = "List of ip addresses for master nodes"
}

variable "worker_ips" {
  type        = list(string)
  description = "List of ip addresses for worker nodes"
}

variable "networkrange" {
  type    = number
  default = 24
}

variable "gateway" {
  type    = string
  default = "192.168.1.254"
}

variable "net_bridge" {
  type    = string
  default = "vmbr0"
}

variable "datastore" {
  type    = string
  default = "local-lvm"
}

variable "disk_interface" {
  type    = string
  default = "scsi0"
}

variable "disk_discard" {
  type    = string
  default = "on"
}

variable "disk_size" {
  type    = number
  default = 10
}
variable "disk_ssd" {
  type    = bool
  default = true
}
