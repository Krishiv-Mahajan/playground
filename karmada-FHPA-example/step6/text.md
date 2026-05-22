### Install metrics-server on member clusters

The FederatedHPA (FHPA) relies on a two-layer metrics pipeline to gather the data needed for autoscaling.

First, the `metrics-server` component must be running on each member cluster. It is responsible for collecting per-pod resource utilization data (such as CPU and memory usage) at the local cluster level.

RUN `bash ~/installMetricsServer.sh`{{exec}}

It automatically downloads the upstream metrics-server manifest, patches it with the `--kubelet-insecure-tls=true` flag for compatibility with our Kind environment, and applies it to both `kind-member1` and `kind-member2`.

> **Note:** Wait a few moments for the `metrics-server` pods to initialize and start capturing data before moving on to the next step.
