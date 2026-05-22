### Configure the Karmada Metrics Adapter

With the local metrics servers running, we now need to bridge that data to the Karmada control plane so the FHPA controller can make global scaling decisions.

**1. Install the `karmada-metrics-adapter`:**
This add-on runs on the Karmada control plane and aggregates the metrics collected from the member clusters.

RUN `bash ~/installMetricsAdapter.sh`{{exec}}

**2. Register the Custom Metrics API:**
Next, we must register the custom metrics `APIService` on both member clusters so the adapter can securely access their local metric endpoints.

RUN `bash ~/installCustomMetricsAPI.sh`{{exec}}

> **Note:** Wait a few moments for the adapter pods to start and the APIService registration to settle before proceeding.
