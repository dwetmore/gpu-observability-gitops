KUSTOMIZE ?= kustomize
KUBECONFORM ?= kubeconform

.PHONY: render validate show-urls

render:
	$(KUSTOMIZE) build .

validate:
	$(KUSTOMIZE) build . | $(KUBECONFORM) -strict -summary -ignore-missing-schemas

show-urls:
	@echo "Grafana:    https://grafana.<NODE_IP>.nip.io"
	@echo "Prometheus: https://prometheus.<NODE_IP>.nip.io"
