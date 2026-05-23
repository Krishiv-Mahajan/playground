### Verify Application Failover

Because of the `OverridePolicy`, the replica scheduled to `member1` is currently failing to pull its image. After the configured `tolerationSeconds` (30s) expires, Karmada detects the unhealthy application state and automatically initiates an Application Failover, re-scheduling the failed replica from `member1` to the healthy cluster (`member2`).

**1. Check pod status in member cluster 1**

Check the pod status in member cluster 1, which is not ready.
RUN `kubectl --kubeconfig ~/.kube/config-member1 --context kind-member1 get pods`{{exec}}

**2. Inspect the resource binding of deployment on control plane**

Check the health status of the deployment's ResourceBinding. You will see that `member1` is marked as `Unhealthy` under `status.aggregatedStatus`.
RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep -A 5 aggregatedStatus`{{exec}}

**3. Watch replica distribution of nginx across member clusters**

New replicas will be scheduled to `member2` after around 30 seconds. Since `purgeMode` is set to `Never` in our PropagationPolicy, the original failed replicas in `cluster1` will remain unless manually deleted (so you can still debug them).

Use the following command to watch the pods across all member clusters in real-time. (Press `Ctrl+C` to exit watch mode once you see `member2` pods running).
RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -w`{{exec}}
