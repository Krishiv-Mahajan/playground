### Initialize Karmada Control Plane

The Karmada control plane is the central management layer that schedules and coordinates workloads across all member clusters.

**Initialize the Karmada control plane:**

RUN `karmadactl init`{{exec}}

This sets up the Karmada control plane on the host Kubernetes cluster, deploying the Karmada API server, controller manager, scheduler, and other core components.

> This step may take **1–2 minutes** to complete.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This ensures that the Karmada API server context is available and configured correctly.
