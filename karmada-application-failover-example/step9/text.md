### Verify Application Failover

Because of the `OverridePolicy`, the replica scheduled to `member1` is currently failing to pull its image. After the configured `tolerationSeconds` (120s) expires, Karmada detects the unhealthy application state and automatically initiates an Application Failover, re-scheduling the failed replica from `member1` to the healthy cluster (`member2`).

1. Monitor the failover in real-time

   Use the following automated polling script to wait for the failover to complete without manually exiting:

   RUN `for i in {1..30}; do CLUSTERS=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.clusters[*].name}'); if [[ "$CLUSTERS" == "kind-member2" ]]; then echo "✓ Failover complete! Application now fully on: $CLUSTERS"; break; fi; echo "Waiting for failover... ($i/30, ~$(($i * 10))s elapsed)"; sleep 10; done`{{exec}}

   This outputs "Waiting for failover..." until the 120s timeout expires. Once Karmada re-evaluates the placement, it will output "✓ Failover complete!" as `member2` takes over fully.

   > **Note:** 
   > If you prefer to watch the failover manually, you can run these commands (use `Ctrl+C` to exit watch mode):
   > - **Watch ResourceBinding:** `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebindings nginx-deployment -o wide -w` (Shows a continuous stream of the ResourceBinding status)
   > - **Watch Pods in member2:** `kubectl --kubeconfig ~/.kube/config-member2 --context kind-member2 get pods -w` (Shows a live stream of pods on member2)

2. Verify the new cluster assignment and the `gracefulEvictionTasks`

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep -A 10 clusters:`{{exec}}

   This displays the active clusters list for the workload, showing that only `kind-member2` is currently assigned. Both replicas have now been assigned to the healthy cluster.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{range .spec.gracefulEvictionTasks[*]}{.fromCluster}{"\t"}{.suppressDeletion}{"\n"}{end}'`{{exec}}

   This outputs `kind-member1    true`. Because our PropagationPolicy set `purgeMode` to `Never`, Karmada keeps the failed pods on `member1` around for debugging purposes. It adds a `gracefulEvictionTasks` entry indicating the cluster failed with an application failure, but deletion is suppressed (`suppressDeletion: true`).

   > **Note:** If `gracefulEvictionTasks` is empty, wait a bit longer and ensure `health: Unhealthy` appears under `aggregatedStatus`.

3. Check Karmada's scheduler events

   Verify that the scheduler explicitly reports the re-scheduling to the new cluster:
   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get events | grep ScheduleBindingSucceed | grep member2`{{exec}}

   This shows the event logged by the scheduler when it re-evaluates the placement, stating that the binding has been scheduled successfully to `kind-member2`.

4. Clean up the failed resources on member1

   To fully evict the application from the failed cluster, we need to set `suppressDeletion` to `false` in the `gracefulEvictionTasks`. This tells Karmada we are done debugging and it can safely delete the legacy resources.

   RUN `TASK_COUNT=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o json | jq '.spec.gracefulEvictionTasks | length'); for i in $(seq 0 $((TASK_COUNT - 1))); do kubectl --kubeconfig /etc/karmada/karmada-apiserver.config patch rb nginx-deployment --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/gracefulEvictionTasks/$i/suppressDeletion\", \"value\": false}]"; done`{{exec}}

   After patching, Karmada purges the broken application from `member1`.

5. Demonstrate final cluster status

   Verify that both replicas are running successfully on the healthy cluster (`member2`):

   RUN `kubectl --kubeconfig ~/.kube/config-member2 --context kind-member2 get pods`{{exec}}

   This lists 2 nginx pods in a "Running" state.

   Verify that the unhealthy cluster (`member1`)'s work has been unscheduled and no pods remain:
   
   RUN `kubectl --kubeconfig ~/.kube/config-member1 --context kind-member1 get pods`{{exec}}

   This outputs "No resources found", confirming the failed cluster has been completely evacuated.
