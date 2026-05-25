### Configure Multi-Cluster Routing

To allow requests to seamlessly route to our `nginx` pod regardless of which member cluster it is scheduled on, we need to configure Karmada Multi-Cluster Services (MCS).

**Apply the MultiClusterService configuration:**

<details>
<summary>multiClusterService.yaml</summary>

```yaml
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
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/multiClusterService.yaml`{{exec}}

This creates a `MultiClusterService` object to enable cross-cluster access for the `nginx-service` across `kind-member1` and `kind-member2`. When a client in one member cluster accesses the service, the request can be automatically routed to backend pods in any cluster.

