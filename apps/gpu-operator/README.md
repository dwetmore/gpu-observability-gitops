# GPU operator notes

This repo deploys the NVIDIA GPU Operator Helm chart with `driver.enabled=false` and `dcgmExporter.enabled=false`.

On MicroK8s/WSL clusters, Node Feature Discovery may not add `feature.node.kubernetes.io/pci-10de.present=true`.
Without that label, the GPU Operator chart logs `No GPU node in the cluster, do not create DaemonSets` and skips DCGM exporter.

To keep GPU metrics working under GitOps, `apps/gpu-operator/extras` contains a standalone DCGM exporter DaemonSet, Service, and ServiceMonitor.
The DaemonSet uses `runtimeClassName: nvidia` and does not require NVIDIA PCI node labels.

The NVIDIA device plugin DaemonSet in `kube-system` is managed by the MicroK8s `nvidia` addon.
If your Prometheus Operator uses different ServiceMonitor labels, adjust `apps/gpu-operator/extras/dcgm-exporter.yaml` metadata labels accordingly.
