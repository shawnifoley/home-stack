# Bootstrap (Tofu + Ansible)

This runbook builds Proxmox VMs with Tofu and configures k3s with Ansible.

## Prereqs

- Proxmox API access
- `tofu`, `ansible`, `kubectl`
- environment vars for Proxmox auth (for example `TF_VAR_pm_api_password`)

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

- Traefik via Helm:
  - `traefik: true`
  - `traefik_chart_version: "v39.0.2"`
- Longhorn via Helm:
  - `longhorn: true`
  - `longhorn_chart_version: "1.10.0"`

## 4) Next step

Deploy manifests via `docs/k8s-ops.md`.
