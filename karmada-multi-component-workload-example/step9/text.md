### Deploy Volcano Application

Now let's repeat the process with a batch AI training workload using **Volcano**. 

Volcano workloads exhibit the same multi-component complexity. An AI training job typically consists of a `ParameterServer` task for coordinating weights, and multiple `Worker` tasks for distributed computation.

**Apply the Volcano Custom Resource and PropagationPolicy:**

<details>
<summary>volcanojob-cr.yaml</summary>

```yaml
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: volcanojob-sample
spec:
  maxRetry: 3
  minAvailable: 3
  plugins:
    env: []
    ssh: []
    svc:
    - --disable-network-policy=true
  queue: default
  schedulerName: volcano
  tasks:
  - minAvailable: 1
    name: job-nginx1
    replicas: 1
    template:
      metadata:
        name: nginx1
      spec:
        containers:
        - args:
          - sleep 10
          command:
          - bash
          - -c
          image: nginx:latest
          imagePullPolicy: IfNotPresent
          name: nginx
          resources:
            requests:
              cpu: 200m
              memory: 100Mi
        nodeSelector:
          kubernetes.io/os: linux
        restartPolicy: OnFailure
  - minAvailable: 2
    name: job-nginx2
    replicas: 3
    template:
      metadata:
        name: nginx2
      spec:
        containers:
        - args:
          - sleep 30
          command:
          - bash
          - -c
          image: nginx:latest
          imagePullPolicy: IfNotPresent
          name: nginx
          resources:
            requests:
              cpu: 100m
              memory: 100Mi
        nodeSelector:
          kubernetes.io/os: linux
        restartPolicy: OnFailure
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/volcanojob-cr.yaml`{{exec}}

This applies the Volcano Custom Resource.

<details>
<summary>volcano-policy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: volcano-propagation
spec:
  resourceSelectors:
    - apiVersion: batch.volcano.sh/v1alpha1
      kind: Job
      name: volcanojob-sample
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1
        minGroups: 1
    replicaScheduling:
      replicaSchedulingType: Divided
      replicaDivisionPreference: Aggregated
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/volcano-policy.yaml`{{exec}}

This applies the Volcano PropagationPolicy.

**Why this matters:**

Just like the Flink job, the Volcano `PropagationPolicy` uses an identical `spreadConstraints` strategy (`maxGroups: 1`) combined with `replicaSchedulingType: Divided`. 

This guarantees that the entire batch AI job is treated as a single indivisible unit. Karmada will schedule all parameter servers and all worker nodes atomically to the exact same target cluster, ensuring your training job doesn't fail due to inter-cluster latency.
