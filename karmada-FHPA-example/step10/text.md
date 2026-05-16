### Observe Scale Down

After the load test completes and traffic subsides, the FederatedHPA will gradually scale down the workload based on the `stabilizationWindowSeconds` and the CPU utilization dropping below the target threshold. This demonstrates the automatic scale-down capability of FederatedHPA across clusters.

**Step 1 — Wait for load to finish:**

The `hey` load test from the previous step ran for 1 minute. After it completes, wait an additional 30–40 seconds for the metrics to stabilize.

**Step 2 — Check the current pod distribution:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

You should still see multiple nginx pods spread across both clusters.

**Step 3 — Monitor CPU utilization drop:**

Check the FederatedHPA status again:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx`{{exec}}

Watch as the `REPLICAS` field begins to decrease as CPU utilization drops below the 10% threshold.

**Step 4 — Observe scale-down progression (optional):**

You can continuously monitor the scale-down by running:

RUN `watch kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx`{{exec}}

Press `Ctrl+C` to exit the watch command.

**Step 5 — Final pod state after scale-down completes:**

Wait approximately 1–2 minutes, then check the final pod distribution:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

The replicas should return to the minimum (1 replica), which can be distributed across one or both clusters depending on the scheduler's decisions.

> **Note:** The exact time to scale down depends on the `stabilizationWindowSeconds` and how quickly metrics update. By default, the downscale is more conservative than upscale to avoid thrashing.

**What You've Learned:**

- FederatedHPA automatically scales workload replicas based on aggregated metrics from multiple clusters
- Scale-up is responsive to load spikes
- Scale-down is gradual and stabilized to prevent unnecessary churn
- The MultiClusterService distributes traffic across clusters, allowing both to be measured and scaled
