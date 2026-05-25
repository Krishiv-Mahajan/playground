### Provide Workload Definitions to Karmada

Before Karmada can schedule complex FlinkDeployment workloads, it needs to understand their structure. 

To achieve this, we must do two things:
1. Apply their **Custom Resource Definitions (CRDs)** to the Karmada control plane and propagate them to the member clusters.
2. Apply **Resource Interpreter Customizations** to teach Karmada how to extract per-component resource requirements from these specific workload types.

> **Note:** Karmada has built-in support for interpreting common third-party multi-component workload resources such as FlinkDeployment. They define rules for Karmada to parse these resources, covering extraction of replicas and resource requirements of each component, judgment of workload health status and identification of dependent resources.

**Apply the CRDs and PropagationPolicy:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/flinkdeployments.flink.apache.org-v1.yaml`{{exec}}

This applies the Flink CRD.

<details>
<summary>crd-propagation-policy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: ClusterPropagationPolicy
metadata:
  name: crd-propagation
spec:
  resourceSelectors:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: flinkdeployments.flink.apache.org
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
```

</details>

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply --validate=false -f /root/examples/crd-propagation-policy.yaml`{{exec}}

This applies the ClusterPropagationPolicy to distribute the CRDs.

**Apply the Resource Interpreters:**

Karmada needs to know exactly how to parse the custom resources to find their component definitions. We provide Lua scripts that teach Karmada how to do this.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f /root/examples/flink-interpreter.yaml`{{exec}}

This applies the interpreter for Flink workloads.

**Verify CRD Propagation:**

Wait a moment for the Karmada controller to sync, then query `member1` directly to ensure the Flink CRD was successfully pushed down to the edge cluster:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 get crd flinkdeployments.flink.apache.org`{{exec}}

This outputs the `flinkdeployments.flink.apache.org` CRD, showing it was successfully pushed to the edge cluster.
