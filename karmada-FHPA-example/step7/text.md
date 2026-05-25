### Configure the Karmada Metrics Adapter

With the local metrics servers running, we now need to bridge that data to the Karmada control plane so the FHPA controller can make global scaling decisions.

**Install the `karmada-metrics-adapter`:**
This add-on runs on the Karmada control plane and aggregates the metrics collected from the member clusters. It also automatically registers the `metrics.k8s.io` and `custom.metrics.k8s.io` APIServices in the control plane, which the FederatedHPA controller uses to fetch metrics.

RUN `bash ~/installMetricsAdapter.sh`{{exec}}

> **Note:** Wait a few moments for the adapter pods to start and the APIService registration to settle before proceeding.
