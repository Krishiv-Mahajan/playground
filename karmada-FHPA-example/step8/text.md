### Create MultiClusterService for Cross-Cluster Access

A **MultiClusterService** enables cross-cluster access between services. When a client in `kind-member1` sends a request to `nginx-service`, the MultiClusterService allows it to be routed to backend pods in **both** `kind-member1` and `kind-member2`. This ensures that load is distributed across both clusters, which is essential for triggering scale-up in both clusters via FederatedHPA.

> **Note:** FederatedHPA does **not** require a MultiClusterService — it works independently. The MultiClusterService here is used to route load testing traffic to both clusters so we can observe cross-cluster scale-up.

**Create the MultiClusterService manifest:**

RUN `cat << 'EOF' > mcs.yaml
apiVersion: networking.karmada.io/v1alpha1
kind: MultiClusterService
metadata:
  name: nginx-service
spec:
  types:
  - CrossCluster
  consumerClusters:
  - name: kind-member1
  - name: kind-member2
  providerClusters:
  - name: kind-member1
  - name: kind-member2
EOF`{{exec}}

**Apply the MultiClusterService:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f mcs.yaml`{{exec}}

**Verify the MultiClusterService:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get multiclusterservice`{{exec}}

The `nginx-service` MultiClusterService should now be listed.

After this, requests sent from `kind-member1` to the `nginx-service` ClusterIP will be load-balanced between pods in both member clusters.
