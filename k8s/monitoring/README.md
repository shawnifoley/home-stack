# Monitoring Stack

This folder scaffolds cluster monitoring with:

- `kube-prometheus-stack` (Prometheus, Alertmanager)
- custom `PrometheusRule` alerts for home-stack workloads and Longhorn

## Install

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f k8s/monitoring/kube-prometheus-stack-values.yaml

kubectl apply -k k8s/monitoring
```

## Verify

```bash
kubectl get pods -n monitoring
kubectl get prometheusrules.monitoring.coreos.com -n monitoring
kubectl get svc -n monitoring
kubectl get ingress -n monitoring
```

## Access UIs

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093
```

## Notes

- `prometheus-rules.yaml` uses label `release: kube-prometheus-stack` so rules are picked up by the chart defaults.
- Longhorn alerts assume Longhorn metrics are available in Prometheus.
