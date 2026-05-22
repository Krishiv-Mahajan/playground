### Deploy the Nginx Workload

We will use a simple Nginx application to demonstrate autoscaling.

**Apply the Nginx Deployment and Service:**

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
  replicas: 1
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
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            cpu: 100m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/nginxDeployment.yaml`{{exec}}

This creates an Nginx workload (with 1 initial replica) and a corresponding `ClusterIP` Service within the Karmada control plane.

> **Crucial Detail for Autoscaling:** Notice that our deployment explicitly defines CPU `requests` and `limits`. CPU-based autoscaling algorithms cannot function without these resource boundaries defined on the container!

**Verify the Deployment:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment nginx`{{exec}}

This command confirms that the Nginx Deployment template has been successfully registered in the control plane.

**Verify the Service:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get service nginx-service`{{exec}}

> **Note:** At this stage, the workload exists *only* as a template in the Karmada control plane. No actual pods have been created yet, as we have not defined how it should be distributed. It will be propagated to the member clusters in the next step.

