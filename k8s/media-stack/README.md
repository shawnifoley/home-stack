# Media Stack (Kustomize)

This folder organizes Sabnzbd, Sonarr, and Radarr into a reusable base with a home-cluster overlay.

## Apply

```bash
kubectl apply -k /Users/sfoley/repos/home-pods/k8s/media-stack/overlays/home
```

## Preview

```bash
kubectl kustomize /Users/sfoley/repos/home-pods/k8s/media-stack/overlays/home
```

## Layout

- `base/`: reusable manifests for apps and storage.
- `overlays/home/`: cluster-specific values (hosts, ingress class, issuer, image policy).
- `overlays/home/extras/`: optional/cluster-local extras such as scheduled rollout restarts.
