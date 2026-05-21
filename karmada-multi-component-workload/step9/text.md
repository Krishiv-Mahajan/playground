Karmada needs to know how to distribute this workload. We will use a `PropagationPolicy` that tells Karmada to:

- **Aggregate all components onto one cluster** using `spreadConstraints` (MaxGroups=1, MinGroups=1)
- **Calculate total resources** from every component using `replicaScheduling: Divided / Aggregated`

This matches the scheduling strategy validated in Karmada's e2e tests for multi-component workloads.

The policy file `job-policy.yaml` was pre-created for you. It looks like this:

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
        - kind-member1
        - kind-member2
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1   # Pin ALL components to ONE cluster
        minGroups: 1
    replicaScheduling:
      replicaDivisionPreference: Aggregated
      replicaSchedulingType: Divided
```

Apply it:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f job-policy.yaml`{{exec}}
