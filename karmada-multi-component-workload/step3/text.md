### Initialize Karmada control plane

**Initialize the Karmada control plane:**

RUN `karmadactl init`{{exec}}

This sets up the Karmada control plane on the host cluster, including the API server, controller manager, scheduler, and webhook.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

**Enable the `MultiplePodTemplatesScheduling` feature gate:**

This feature gate (Alpha, introduced in v1.16) is required for Karmada to populate `spec.components` in ResourceBindings — the field that proves Karmada understood the per-component resource requirements of your VolcanoJob. It must be enabled on the controller-manager, scheduler, and webhook.

RUN `bash enable-feature-gate.sh`{{exec}}

This script patches all three deployments and waits for the rollout to complete. It is equivalent to adding `--feature-gates=MultiplePodTemplatesScheduling=true` to each component's command arguments.
