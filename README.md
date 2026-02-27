# home-stack

Kubernetes manifests for home media services and supporting cluster resources.

## Repo Layout

- `k8s/infra/`: cluster-wide resources
  - `StorageClass` (Longhorn)
  - NFS `PersistentVolume`
  - cert-manager `ClusterIssuer`
- `k8s/media-stack/`: Sabnzbd, Sonarr, Radarr via Kustomize
  - `base/`: reusable app manifests
  - `overlays/home/`: home-cluster values (hosts, ingress class, issuer, storage class)
  - `overlays/home/extras/`: scheduled restart CronJobs

## Deploy Order

1. Apply infra:

```bash
kubectl apply -k k8s/infra
```

2. Apply media stack:

```bash
kubectl apply -k k8s/media-stack/overlays/home
```

## Useful Commands

Preview rendered manifests:

```bash
kubectl kustomize k8s/infra
kubectl kustomize k8s/media-stack/overlays/home
```

Rollout status:

```bash
kubectl rollout status deployment/sabnzbd -n media
kubectl rollout status deployment/sonarr -n media
kubectl rollout status deployment/radarr -n media
```

Force restart now:

```bash
kubectl rollout restart deployment/sabnzbd -n media
kubectl rollout restart deployment/sonarr -n media
kubectl rollout restart deployment/radarr -n media
```

Access UIs with port-forward:

```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
kubectl -n kube-system port-forward svc/traefik 9000:9000
```

## Notes

- `nfs-export-root` maps to your NFS share root.
- Mounting without `subPath` mounts the root of the PVC.
- Current app namespace is `media`.
- Backups use Longhorn recurring backups to NFS (set backup target in Longhorn first).
- Fresh-cluster restore steps: `docs/longhorn-dr-runbook.md`.

## Longhorn Backup Attach (Existing Volumes)

For pre-existing Longhorn volumes, attach recurring jobs once by labeling the `Volume` CRs:

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

## Troubleshooting

PVC/PV not binding:

```bash
kubectl get pv,pvc -n media
kubectl describe pvc nfs-export-root -n media
kubectl describe pv nfs-export-root
```

Pods stuck Pending or CrashLoopBackOff:

```bash
kubectl get pods -n media
kubectl describe pod -n media <pod-name>
kubectl logs -n media <pod-name> --previous
```

Deployment rollout not progressing:

```bash
kubectl rollout status deployment/sabnzbd -n media
kubectl rollout status deployment/sonarr -n media
kubectl rollout status deployment/radarr -n media
kubectl describe deployment/sabnzbd -n media
```

Ingress or TLS not reachable:

```bash
kubectl get ingress -n media
kubectl describe ingress sabnzbd -n media
kubectl get certificate,certificaterequest -n media
kubectl get challenge,order -n media
```

Confirm DNS resolves to your ingress endpoint:

```bash
dig +short sabnzbd.fol3y.us
dig +short sonarr.fol3y.us
dig +short radarr.fol3y.us
```
