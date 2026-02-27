# Media Stack (Kustomize)

This folder organizes Sabnzbd, Sonarr, and Radarr into a reusable base with a home-cluster overlay.

## Apply

```bash
kubectl apply -k k8s/media-stack/overlays/home
```

## Preview

```bash
kubectl kustomize k8s/media-stack/overlays/home
```

## Layout

- `base/`: reusable manifests for apps and storage.
- `overlays/home/`: cluster-specific values (hosts, ingress class, issuer, image policy).
- `overlays/home/extras/`: optional/cluster-local extras such as scheduled rollout restarts.

## Backup Behavior

- Longhorn recurring backup jobs are attached to Longhorn PVCs via labels; ensure Longhorn backup target (NFS) is configured in Longhorn settings.
- For existing volumes, attach jobs once by labeling Longhorn `Volume` resources:

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
