# Create Deployment

In this step, we will create a standard Kubernetes Deployment for our application. This Deployment will serve as the target for our application failover demonstration.

**Create a deployment named `nginx` with 2 replicas:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/nginxDeployment.yaml`{{exec}}

<details>
<summary>nginxDeployment.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

</details>

This creates the base `nginx` workload in the Karmada control plane. At this point, the application is not yet distributed to the member clusters because we haven't defined a PropagationPolicy.

**Verify deployment exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment nginx`{{exec}}

This confirms that the `nginx` deployment exists in the control plane, ready to be propagated.
