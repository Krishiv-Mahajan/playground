Now, you will create a Volcano Job. This custom resource contains multiple nested components, each requiring different resources.

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
      name: job-nginx1
      template:
        spec:
          containers:
            - name: container-nginx1
              image: nginx
              resources:
                requests:
                  cpu: "200m"
                  memory: "100Mi"
    - replicas: 2
      name: job-nginx2
      template:
        spec:
          containers:
            - name: container-nginx2
              image: nginx
              resources:
                requests:
                  cpu: "100m"
                  memory: "100Mi"
```

Command to run:

```bash
kubectl apply -f volcano-job.yaml
```
