### Deploy FederatedHPA

A **FederatedHPA** (FederatedHorizontalPodAutoscaler) works like a standard Kubernetes HPA but operates across multiple clusters. It aggregates CPU (or memory) metrics from all member clusters via the `karmada-metrics-adapter` and scales the workload's replicas globally.

In this step, we configure FederatedHPA to:
- Target the `nginx` Deployment
- Scale between **1** and **10** replicas
- Trigger scale-up when average CPU utilization exceeds **10%** (low threshold to easily trigger in a lab)
- Use a 10-second stabilization window for both scale-up and scale-down

**Create the FederatedHPA manifest:**

RUN `cat << 'EOF' > fhpa.yaml
apiVersion: autoscaling.karmada.io/v1alpha1
kind: FederatedHPA
metadata:
  name: nginx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 10
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
    scaleUp:
      stabilizationWindowSeconds: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
EOF`{{exec}}

**Apply the FederatedHPA:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f fhpa.yaml`{{exec}}

**Verify the FederatedHPA was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa`{{exec}}

You should see the `nginx` FederatedHPA with `MINPODS: 1`, `MAXPODS: 10`, and `REPLICAS: 1`.

> **How it works:** The `karmada-metrics-adapter` (enabled in the background setup) aggregates resource metrics from `metrics-server` instances on each member cluster and exposes them to the FederatedHPA controller running in the Karmada control plane.
