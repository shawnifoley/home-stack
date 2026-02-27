pm_host             = "pve.fol3y.us"
pm_node_name        = "pve"
deployment_name     = "dev"
host_user           = "sfoley"
pub_key             = "~/.ssh/id_ed25519.pub"
pvt_key             = "~/.ssh/id_ed25519"
template_id         = 1002
cpu_cores           = 4
num_k3s_masters_mem = 5120
num_k3s_workers_mem = 5120
disk_size           = 32
pool_id             = "dev"
tags                = ["dev", "k8s"]

# Set credentials via environment variables (recommended):
# export TF_VAR_pm_api_password="..."

master_ips = [
  "192.168.1.21",
]
worker_ips = [
  "192.168.1.22",
  "192.168.1.23"
]
