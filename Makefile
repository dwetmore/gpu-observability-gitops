KUSTOMIZE ?= kustomize
KUBECONFORM ?= kubeconform

.PHONY: render validate show-urls

render:
	$(KUSTOMIZE) build .

validate:
	$(KUSTOMIZE) build . | $(KUBECONFORM) -strict -summary -ignore-missing-schemas

show-urls:
	@echo "Grafana:    https://grafana.172.17.93.185.nip.io"
	@echo "Prometheus: https://prometheus.172.17.93.185.nip.io"
