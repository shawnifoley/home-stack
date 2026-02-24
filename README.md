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

## Notes

- Using `Longhorn` until `Postgres` is setup for `sonarr`|`radarr`.
- `nfs-export-root` maps to your NFS share root.
- Mounting without `subPath` mounts the root of the PVC.
- Current app namespace is `media`.
- Backup CronJobs use `preferred` pod affinity (same-node preference, not a hard requirement) to improve schedule reliability.

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
