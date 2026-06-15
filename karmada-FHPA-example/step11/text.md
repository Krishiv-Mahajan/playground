### Deploy the FederatedHPA

Now we apply the actual autoscaling policy.

**Apply the FederatedHPA:**

<details>
<summary>federatedHPA.yaml</summary>

```yaml
apiVersion: autoscaling.karmada.io/v1alpha1
kind: FederatedHPA
metadata:
  name: nginx-fhpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 4
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
    scaleUp:
      stabilizationWindowSeconds: 0
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/federatedHPA.yaml`{{exec}}

This creates a `FederatedHPA` that monitors the CPU utilization of all Nginx pods across both member clusters via the `karmada-metrics-adapter`.

- When average CPU utilization exceeds **10%**, it triggers a scale-up (to a maximum of 4 replicas).
- When the load drops below the threshold, it scales back down (to a minimum of 1 replica).
- The stabilization window is deliberately set very short (10 seconds) so we can observe the scaling actions quickly in this tutorial.

**Verify the FederatedHPA:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

You should see `nginx-fhpa` listed with `MINPODS=1`, `MAXPODS=4`, and `REPLICAS=1`.
