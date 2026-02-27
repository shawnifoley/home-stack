# Kubernetes Ops

## Deploy Order

```bash
kubectl apply -k k8s/infra
kubectl apply -k k8s/media-stack/overlays/home
```

## ArgoCD

Apply app definitions:

```bash
kubectl apply -k k8s/argocd
```

Notes:

- `home-infra` sync wave `-1`
- `home-media` sync wave `0`
- Update `repoURL` placeholders in `k8s/argocd/*.yaml` before first apply

## Validate

```bash
kubectl kustomize k8s/infra
kubectl kustomize k8s/media-stack/overlays/home

kubectl rollout status deployment/sabnzbd -n media
kubectl rollout status deployment/sonarr -n media
kubectl rollout status deployment/radarr -n media
kubectl rollout status deployment/vaultwarden -n media
```

## Access UIs

```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
kubectl -n kube-system port-forward svc/traefik 9000:9000
```

## Longhorn Backups

Recurring jobs and backup target are managed in `k8s/infra`.

Check:

```bash
kubectl -n longhorn-system get backuptargets.longhorn.io default -o wide
kubectl -n longhorn-system get recurringjobs.longhorn.io
kubectl -n longhorn-system get backups.longhorn.io -o wide
```

### Existing volumes: one-time recurring-job attach

```bash
kubectl -n media get pvc sonarr-config radarr-config vaultwarden-data \
  -o custom-columns=PVC:.metadata.name,VOLUME:.spec.volumeName

kubectl -n longhorn-system label volumes.longhorn.io <sonarr-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-sonarr-weekly=enabled --overwrite

kubectl -n longhorn-system label volumes.longhorn.io <radarr-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-radarr-weekly=enabled --overwrite

kubectl -n longhorn-system label volumes.longhorn.io <vaultwarden-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-vaultwarden-daily=enabled --overwrite
```

## Restore

See `docs/longhorn-dr-runbook.md`.
