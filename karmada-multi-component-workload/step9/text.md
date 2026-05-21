Karmada needs to know how to distribute this workload. We will use a PropagationPolicy that tells Karmada to calculate the total resources and attempt to keep the components together if possible.

Create `job-policy.yaml`:

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: ai-training-policy
  namespace: default
spec:
  resourceSelectors:
    - apiVersion: batch.volcano.sh/v1alpha1
      kind: Job
      name: ai-training-job
  placement:
    clusterAffinity:
      clusterNames:
        - cluster1
        - cluster2
    replicaScheduling:
      replicaDivisionPreference: Aggregated
      replicaSchedulingType: Divided
```

Command to run:

```bash
kubectl apply -f job-policy.yaml
```
