This is the core of the tutorial. Inspect the ResourceBinding that Karmada automatically generated. This proves that Karmada successfully parsed the custom resource and extracted the requirements of both components.

Command to run:

```bash
kubectl get resourcebinding ai-training-job -n default -o yaml
```

Look for the `spec.components` section in the terminal output. You will see that Karmada has mathematically mapped out the requirements for both the driver (1 replica, 500m CPU) and the worker (2 replicas, 1 CPU each).
