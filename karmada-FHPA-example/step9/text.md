### Test Scaling Up with Load

Now we will generate HTTP traffic against the nginx service using [`hey`](https://github.com/rakyll/hey), a fast HTTP load testing tool. This will push CPU utilization above the 10% threshold we configured in the FederatedHPA, triggering a scale-up across both clusters.

**Step 1 — Check the current pod distribution:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

You should see one nginx pod running in `kind-member1` initially.

**Step 2 — Get the `nginx-service` ClusterIP in `kind-member1`:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

Note the `CLUSTER-IP` for `nginx-service` in the `kind-member1` row. You will use this IP in the next command.

**Step 3 — Run the load test from inside the `kind-member1` cluster:**

Replace `<CLUSTER-IP>` with the actual IP from the previous command:

RUN `SVC_IP=$(kubectl --kubeconfig=$HOME/.kube/config-member1 --context=kind-member1 get svc nginx-service -o jsonpath='{.spec.clusterIP}')`{{exec}}

RUN `docker exec member1-control-plane hey -c 1000 -z 1m http://${SVC_IP}`{{exec}}

This runs 1000 concurrent requests for 1 minute against the nginx service, routing traffic through both clusters via the MultiClusterService.

**Step 4 — Wait ~15 seconds, then observe scale-up:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

You should now see multiple nginx pods spread across **both** `kind-member1` and `kind-member2`!

**Step 5 — Check the FederatedHPA status:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx`{{exec}}

The `REPLICAS` count should have increased from 1.
