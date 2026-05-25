# Create Failover Policies

Now we will configure the Application Failover rules and intentionally inject a fault to trigger the failover process. 

Karmada's Application Failover feature ensures that if an application fails to run on a healthy cluster (e.g., due to `CrashLoopBackOff` or `ImagePullBackOff`), Karmada will automatically migrate the application to another available cluster.

To demonstrate this, we will deploy an `OverridePolicy` and a `PropagationPolicy` in sequence.

**1. Deploy an OverridePolicy first.** 
This policy intentionally breaks the application on `member1` by replacing the container image registry with a non-existent one (`non-existent-registry`). This will cause an `ImagePullBackOff` error on `member1`.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/overridePolicy.yaml`{{exec}}

<details>
<summary>overridePolicy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: OverridePolicy
metadata:
  name: nginx-override
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
  overrideRules:
    - targetCluster:
        clusterNames:
          - kind-member1
      overriders:
        imageOverrider:
          - component: Registry
            operator: replace
            value: non-existent-registry
```

</details>

> **Note:** Please wait for about 3 seconds before proceeding to the next step. This pause ensures the `OverridePolicy` is fully created and detected by Karmada before the `PropagationPolicy` is applied. It helps avoid race conditions where pods might start correctly before the image override takes effect.

**2. Then deploy a PropagationPolicy.** 
This policy distributes the 2 replicas evenly between `member1` and `member2`. Crucially, it includes an `application` failover configuration with a `tolerationSeconds` of 30s (Karmada waits 30 seconds before initiating failover) and `purgeMode: Never` (Karmada will permanently retain the failed pods until manually deleted, allowing for debugging). For more configurations, refer to the [Application Failover documentation](https://karmada.io/docs/userguide/failover/application-failover/).

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/propagationPolicy.yaml`{{exec}}

<details>
<summary>propagationPolicy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  failover:
    application:
      decisionConditions:
        tolerationSeconds: 30
      purgeMode: Never
  propagateDeps: true
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    replicaScheduling:
      replicaDivisionPreference: Aggregated
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
```

</details>

> **Note:** When an application migrates from one cluster to another, it needs to ensure that its dependencies are migrated synchronously. Therefore, you need to ensure that `propagateDeps: true` is set in the propagation policy.
