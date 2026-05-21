Now, you will create a Volcano Job. This CR contains multiple nested components (in this case, two different tasks: driver and worker), each requiring different resources.

Create `volcano-job.yaml`:

```yaml
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: ai-training-job
  namespace: default
spec:
  minAvailable: 3
  schedulerName: volcano
  tasks:
    - replicas: 1
      name: driver
      template:
        spec:
          containers:
            - name: driver-container
              image: nginx
              resources:
                requests:
                  cpu: "500m"
                  memory: "256Mi"
    - replicas: 2
      name: worker
      template:
        spec:
          containers:
            - name: worker-container
              image: nginx
              resources:
                requests:
                  cpu: "1"
                  memory: "512Mi"
```

Command to run:

```bash
kubectl apply -f volcano-job.yaml
```
