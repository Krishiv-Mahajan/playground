### Initialize Karmada control plane

**Initialize Karmada control plane with multi-component scheduling enabled:**

RUN `karmadactl init --config karmada-init-config.yaml`{{exec}}

This sets up the Karmada control plane and enables the `MultiplePodTemplatesScheduling` feature gate on the controller-manager, scheduler, and webhook. This feature gate is required for `spec.components` to be populated in ResourceBindings — which is what allows Karmada to understand the per-component resource requirements of multi-component workloads like VolcanoJob.

The config file enables the feature gate on all three required components:
```yaml
karmadaControllerManager:
  extraArgs:
    - --feature-gates=MultiplePodTemplatesScheduling=true
karmadaScheduler:
  extraArgs:
    - --feature-gates=MultiplePodTemplatesScheduling=true
karmadaWebhook:
  extraArgs:
    - --feature-gates=MultiplePodTemplatesScheduling=true
```

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This ensures that the Karmada API server context is available and configured correctly.
