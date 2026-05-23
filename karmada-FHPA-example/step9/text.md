### Define the Propagation Policy

To distribute our Nginx workload across the member clusters, we need to create a `PropagationPolicy`.

**Apply the PropagationPolicy:**

<details>
<summary>propagationPolicy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
    - apiVersion: v1
      kind: Service
      name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    replicaScheduling:
      replicaDivisionPreference: Weighted
      replicaSchedulingType: Divided
      weightPreference:
        staticWeightList:
          - targetCluster:
              clusterNames:
                - kind-member1
            weight: 1
          - targetCluster:
              clusterNames:
                - kind-member2
            weight: 1
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/propagationPolicy.yaml`{{exec}}

This policy targets our Nginx Deployment and Service. It uses `replicaDivisionPreference: Weighted` with a 1:1 static weight ratio, meaning Karmada will attempt to distribute replicas evenly across `kind-member1` and `kind-member2`.

**Verify the Policy:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

**Verify Pod Distribution on Member Clusters:**

Let's check if the pods are actually running:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

> **Note:** It takes a brief moment for the scheduler to distribute the workload and for the clusters to pull the container image. If the command returns "No resources found", wait ~30 seconds and run it again. Since our initial replica count is 1, you should see exactly 1 pod running on one of the member clusters.

