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
kubectl apply -k /Users/sfoley/repos/home-stack/k8s/infra
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

## 3) Restore volumes from Longhorn backups

Use Longhorn UI (`Backup` page):
```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
```

1. Select the latest good backup for each app volume.
2. Restore each backup to a new Longhorn volume.
3. For each restored volume, use Longhorn's `Create PV/PVC` action and create PVCs in namespace `media`.

Restored PVC names:

- `sonarr-config-restore`
- `radarr-config-restore`
- `vaultwarden-data-restore`

## 4) Deploy apps and point them at restored PVCs

Apply stack:

```bash
kubectl apply -k /Users/sfoley/repos/home-stack/k8s/media-stack/overlays/home
```

Patch deployments to use restored PVC names (temporary during DR):

```bash
kubectl -n media patch deployment sonarr --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/volumes/0/persistentVolumeClaim/claimName","value":"sonarr-config-restore"}]'

kubectl -n media patch deployment radarr --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/volumes/0/persistentVolumeClaim/claimName","value":"radarr-config-restore"}]'

kubectl -n media patch deployment vaultwarden --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/volumes/0/persistentVolumeClaim/claimName","value":"vaultwarden-data-restore"}]'
```

Wait for rollouts:

```bash
kubectl rollout status deployment/sonarr -n media
kubectl rollout status deployment/radarr -n media
kubectl rollout status deployment/vaultwarden -n media
```

## 5) Re-attach recurring backups to restored volumes

Map restored PVCs to Longhorn volume names:

```bash
kubectl -n media get pvc sonarr-config-restore radarr-config-restore vaultwarden-data-restore \
  -o custom-columns=PVC:.metadata.name,VOLUME:.spec.volumeName
```

Label each Longhorn `Volume` CR (one-time attach):

```bash
kubectl -n longhorn-system label volumes.longhorn.io <sonarr-restore-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-sonarr-weekly=enabled --overwrite

kubectl -n longhorn-system label volumes.longhorn.io <radarr-restore-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-radarr-weekly=enabled --overwrite

kubectl -n longhorn-system label volumes.longhorn.io <vaultwarden-restore-volume-name> \
  recurring-job.longhorn.io/source=enabled \
  recurring-job.longhorn.io/backup-vaultwarden-daily=enabled --overwrite
```

## 6) Validate end state

```bash
kubectl get pods -n media
kubectl -n longhorn-system get backups.longhorn.io -o wide
kubectl -n longhorn-system get recurringjobs.longhorn.io
```
