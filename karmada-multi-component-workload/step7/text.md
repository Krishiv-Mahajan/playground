Member clusters also need to understand the Volcano Job API before they can accept the workloads. We use a ClusterPropagationPolicy to push the CRD down to the member clusters.

Create and apply this file (`crd-policy.yaml`):

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: ClusterPropagationPolicy
metadata:
  name: volcano-job-crd-cpp
spec:
  resourceSelectors:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: jobs.batch.volcano.sh
  placement:
    clusterAffinity:
      clusterNames:
        - cluster1
        - cluster2
```

Command to run:

```bash
kubectl apply -f crd-policy.yaml
```
