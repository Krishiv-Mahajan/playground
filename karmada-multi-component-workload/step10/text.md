This is the core of the tutorial. Inspect the ResourceBinding that Karmada automatically created when you applied the PropagationPolicy.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job-job -n default -o yaml`{{exec}}

**What to look for in the output:**

**1. `spec.components` — per-task resource breakdown**

This is the key output that proves Karmada understood the internal structure of the VolcanoJob. The `GetComponents` Lua function extracted each task's replica count and resource requirements:

```yaml
spec:
  components:
  - name: job-nginx1
    replicas: 1
    replicaRequirements:
      resourceRequest:
        cpu: 200m
        memory: 100Mi
  - name: job-nginx2
    replicas: 2
    replicaRequirements:
      resourceRequest:
        cpu: 100m
        memory: 100Mi
```

This means Karmada knows the **total cluster requirement** is `400m CPU + 300Mi RAM` before it picks a cluster.

**2. `spec.clusters` — single-cluster placement**

The `spreadConstraints` (MaxGroups=1) forced all components onto exactly **one** cluster:
```yaml
spec:
  clusters:
  - name: kind-member1
```

**3. `status.conditions` — scheduling confirmation**
```yaml
status:
  conditions:
  - type: Scheduled
    status: "True"
    message: Binding has been scheduled successfully.
  - type: FullyApplied
    status: "True"
    message: All works have been successfully applied
```
