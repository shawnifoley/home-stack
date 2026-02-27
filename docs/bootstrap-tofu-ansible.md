# Bootstrap (Tofu + Ansible)

This runbook builds Proxmox VMs with Tofu and configures k3s with Ansible.

## Prereqs

- Proxmox API access
- `tofu`, `ansible`, `kubectl`
- environment vars for Proxmox auth (for example `TF_VAR_pm_api_password`)

## Proxmox Template Setup (One-Time)

Prepare Ubuntu cloud image with `qemu-guest-agent`, import into Proxmox, then convert to template:

```bash
apt-get install -y libguestfs-tools
wget https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img
virt-customize -a ubuntu-22.04-server-cloudimg-amd64.img --install qemu-guest-agent

export vmid=1002
qm create $vmid --name "ubuntu-jammy-cloudinit-template" --memory 2048 --net0 virtio,bridge=vmbr0
mv ubuntu-22.04-server-cloudimg-amd64.img ubuntu-22.04-server-cloudimg-amd64.qcow2
qm importdisk $vmid ubuntu-22.04-server-cloudimg-amd64.qcow2 local-lvm
qm set $vmid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1002-disk-0
qm set $vmid --ide2 local-lvm:cloudinit
qm set $vmid --bootdisk scsi0
qm template $vmid
```

## 1) Tofu (provision VMs)

Per environment:

```bash
cd tofu
tofu init
tofu plan --var-file=variables.dev.tfvars
tofu apply --var-file=variables.dev.tfvars
```

Make targets:

```bash
make tofu-plan-dev
make tofu-apply-dev
make tofu-plan-prod
make tofu-apply-prod
```

Outputs:

- `ansible/inventory/dev/hosts.ini`
- `ansible/inventory/prod/hosts.ini`

## 2) Ansible (install/configure k3s)

Environment-specific vars:

- `ansible/inventory/dev/group_vars/all.yml`
- `ansible/inventory/prod/group_vars/all.yml`

Run:

```bash
cd ansible
ansible-playbook -i inventory/dev/hosts.ini main.yml
```

Make targets:

```bash
make ansible-dev
make ansible-prod
```

Expected:

- kubeconfig copied locally as `~/.kube/kubeconfig-{dev|prod}`

## 3) Optional feature flags

- ArgoCD:
  - `argocd: true|false`
  - `argocd_version: "<tag>"`
  - `argocd_domain: "<fqdn>"`
- Traefik via Helm:
  - `traefik: true|false`
  - `traefik_chart_version: "<chart-version>"`
- cert-manager:
  - `cert_manager: true|false`
  - `cert_manager_version: "<chart-version>"`
  - `cert_manager_create_cloudflare_secret: true|false`
  - `cloudflare_email: "<email>"`
- Longhorn via Helm:
  - `longhorn: true|false`
  - `longhorn_chart_version: "<chart-version>"`
- MetalLB:
  - `metallb: true|false`
  - `metallb_version: "<tag>"`
  - `metallb_range: "<start-ip>-<end-ip>"`

These are set per environment in:

- `ansible/inventory/dev/group_vars/all.yml`
- `ansible/inventory/prod/group_vars/all.yml`

## 4) Next step

Deploy manifests via [docs/k8s-ops.md](k8s-ops.md).
