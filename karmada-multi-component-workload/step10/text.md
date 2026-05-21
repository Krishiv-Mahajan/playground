This is the core of the tutorial. Inspect the ResourceBinding that Karmada automatically generated. This proves that Karmada successfully parsed the custom resource and extracted the requirements of both components.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding job-ai-training-job -n default -o yaml`{{exec}}

Look for the `spec.components` section. You should see **exactly 2 entries** — one per VolcanoJob task:

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

Karmada summed these up to decide which cluster can accommodate the **total** demand before scheduling.
