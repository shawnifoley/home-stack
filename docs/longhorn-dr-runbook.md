# Longhorn DR Runbook (Fresh Cluster)

## Scope

- Restore app data for:
  - `sonarr-config`
  - `radarr-config`
  - `vaultwarden-data`
- Reconnect workloads in namespace `media`
- Re-enable recurring Longhorn backups

## 1) Bootstrap core manifests

Apply infra first (includes Longhorn backup target + recurring jobs):

```bash
kubectl apply -k k8s/infra
```

Check backup target health:

```bash
kubectl -n longhorn-system get backuptargets.longhorn.io default -o wide
```

Expected: `AVAILABLE=true`.

## 2) Verify backups are visible

```bash
kubectl -n longhorn-system get backupvolumes.longhorn.io
kubectl -n longhorn-system get backups.longhorn.io -o wide
```

Expected: backup objects exist for Sonarr, Radarr, and Vaultwarden.

Apply stack and take services down

```bash
kubectl apply -k k8s/media-stack/overlays/home
```

Wait for rollouts:

```bash
kubectl rollout status deployment/sonarr -n media
kubectl rollout status deployment/radarr -n media
kubectl rollout status deployment/vaultwarden -n media
```

Take nodes dowwn to restore volumes

```
kubectl -n media scale deploy vaultwarden --replicas=0
kubectl -n media scale deploy sonarr --replicas=0
kubectl -n media scale deploy radarr --replicas=0
```

## 3) Restore volumes from Longhorn backups

Use Longhorn UI (`Backup` page):
```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
```

1. Delete `detached` volumes ( vaultwarden, sonar, radarr )
2. Restore each backup to a new Longhorn volume.
3. For each restored volume, go to `Operation` -> `Create PV/PVC` action and create PVCs in namespace `media`.

## 4) 

Bring nodes backup with restored volumes

```bash
kubectl -n media scale deploy vaultwarden --replicas=1
kubectl -n media scale deploy sonarr --replicas=1
kubectl -n media scale deploy radarr --replicas=1
```

## 5) Re-attach recurring backups to restored volumes

Map PVCs to Longhorn volume names:

```bash
kubectl -n media get pvc sonarr-config radarr-confige vaultwarden-data \
  -o custom-columns=PVC:.metadata.name,VOLUME:.spec.volumeName
```

Label each Longhorn `Volume` CR (one-time attach):

```bash
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

## 6) Validate end state

```bash
kubectl get pods -n media
kubectl -n longhorn-system get backups.longhorn.io -o wide
kubectl -n longhorn-system get recurringjobs.longhorn.io
```
