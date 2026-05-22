# Create Failover Policies

Now we will configure the Application Failover rules and intentionally inject a fault to trigger the failover process. 

Karmada's Application Failover feature ensures that if an application fails to run on a healthy cluster (e.g., due to `CrashLoopBackOff` or `ImagePullBackOff`), Karmada will automatically migrate the application to another available cluster.

To demonstrate this, we will use a script that applies two policies:
1. **OverridePolicy**: This policy intentionally breaks the application on `member1` by replacing the container image registry with a non-existent one (`non-existent-registry`). This will cause an `ImagePullBackOff` error on `member1`.
2. **PropagationPolicy**: This policy distributes the 2 replicas evenly between `member1` and `member2`. Crucially, it includes an `application` failover configuration with a `tolerationSeconds` of 120s (Karmada waits 120 seconds before initiating failover) and `purgeMode: Never` (Karmada will not immediately delete the failed pods to allow for debugging).

**Run the policy creation script:**

RUN `~/nginx/apply-policies.sh`{{exec}}

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
        tolerationSeconds: 120
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

This script ensures the `OverridePolicy` is applied *before* the `PropagationPolicy` to avoid race conditions where pods might start correctly before the image override takes effect.

**Verify PropagationPolicy exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

This confirms that the policies are successfully created. Karmada will now attempt to deploy 1 replica to `member1` (which will fail) and 1 replica to `member2` (which will succeed).
