# Media Stack (Kustomize)

This folder organizes Sabnzbd, Sonarr, Radarr, and Vaultwarden into a reusable base with a home-cluster overlay.

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

- Longhorn recurring backups are managed in `k8s/infra`.
- For operational commands and one-time volume attach steps, use `docs/k8s-ops.md`.
