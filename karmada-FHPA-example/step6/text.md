### Deploy nginx Workload Across Clusters

We will deploy an nginx `Deployment` (with resource requests and limits required for HPA) along with a `Service` and a `PropagationPolicy` to distribute replicas across both member clusters.

The `PropagationPolicy` uses **Divided** scheduling with equal weights so that replicas are split evenly between `kind-member1` and `kind-member2`.

**Create the manifest:**

RUN `cat << 'EOF' > nginx-fhpa.yaml
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
            cpu: 25m
            memory: 64Mi
          limits:
            cpu: 25m
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
---
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  resourceSelectors:
  - apiVersion: apps/v1
    kind: Deployment
    name: nginx
  - apiVersion: v1
    kind: Service
    name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
      - kind-member1
      - kind-member2
    replicaScheduling:
      replicaDivisionPreference: Weighted
      replicaSchedulingType: Divided
      weightPreference:
        staticWeightList:
        - targetCluster:
            clusterNames:
            - kind-member1
          weight: 1
        - targetCluster:
            clusterNames:
            - kind-member2
          weight: 1
EOF`{{exec}}

**Apply the manifest to the Karmada control plane:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f nginx-fhpa.yaml`{{exec}}

**Verify pods and services are propagated to member clusters:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

You should see an nginx Pod running in `kind-member1`.

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

You should see `nginx-service` present in both `kind-member1` and `kind-member2`.

> **Note:** CPU `requests` and `limits` are required for the HPA to calculate CPU utilization percentage.
