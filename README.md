# gpu-observability-gitops

Pure GitOps GPU observability stack for single-node MicroK8s using Argo CD app-of-apps.

## Architecture

```text
NVIDIA GPU Operator
  └─ DCGM Exporter --metrics--> Prometheus (kube-prometheus-stack) --> Grafana dashboards

Kubernetes Pod Logs --> Promtail --> Loki --> Grafana Explore / Logs panels
```

## Repository layout

```text
kustomization.yaml         # Argo CD repo entrypoint (root kustomize)
apps.yaml                  # Argo CD root Application (points at repo root)
apps/
  gpu-operator/
    application.yaml
  monitoring/
    application.yaml
    extras/
      kustomization.yaml
      dashboards/
  logging/
    application.yaml
Makefile
```

## Prerequisites (MicroK8s host)

- NVIDIA driver installed on host and `nvidia-smi` works.
- MicroK8s ingress controller enabled and using ingress class `public`.
- A default storage class is available for Prometheus/Grafana/Loki PVCs.
- Argo CD installed in the cluster.

## Install

1. Apply the Argo CD root application:

```bash
kubectl apply -f apps.yaml
```

2. Sync apps:

```bash
kubectl -n argocd get applications
kubectl -n argocd annotate application gpu-observability-root argocd.argoproj.io/refresh=hard --overwrite
```

3. Check expected URLs (replace `<NODE_IP>`):

- `https://grafana.<NODE_IP>.nip.io`
- `https://prometheus.<NODE_IP>.nip.io`

## Verification

### 1) Pods are running

```bash
kubectl get pods -n gpu-operator
kubectl get pods -n monitoring
kubectl get pods -n logging
```

### 2) Prometheus sees DCGM exporter target

- Open Prometheus Targets page at `https://prometheus.<NODE_IP>.nip.io/targets`.
- Verify `dcgm-exporter` target is `UP`.

### 3) Grafana dashboards show GPU metrics

- Open Grafana at `https://grafana.<NODE_IP>.nip.io`.
- Confirm **GPU DCGM Overview** dashboard shows utilization, memory, temperature, and power panels.
- Confirm **Node Basic** dashboard shows CPU/memory/disk panels.

### 4) Loki datasource and logs

Run a test pod:

```bash
kubectl run log-demo --image=busybox -n default -- /bin/sh -c 'while true; do echo hello-loki; sleep 5; done'
```

Then in Grafana Explore:

- Select **Loki** datasource.
- Query `{namespace="default", pod="log-demo"}` and verify logs appear.
