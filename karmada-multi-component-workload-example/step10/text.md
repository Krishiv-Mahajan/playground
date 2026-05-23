### Inspect the Volcano ResourceBinding

Just like we did for the Flink workload, let's inspect the `ResourceBinding` that Karmada generated for the Volcano Job to see how its components were extracted.

First, extract the dynamic binding name into a variable. Notice that we filter specifically for the `batch.volcano.sh/v1alpha1` API version:

RUN `V_BINDING=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding -n default -o json | jq -r '.items[] | select(.spec.resource.kind=="Job" and .spec.resource.apiVersion=="batch.volcano.sh/v1alpha1") | .metadata.name')`{{exec}}

**Verify Component Extraction:**

Check the specific names of the components Karmada extracted for the Volcano Job:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $V_BINDING -n default -o json | jq '.spec.components[].name'`{{exec}}

This outputs `"job-nginx1"` and `"job-nginx2"`.

> **Note:** `job-nginx2` has **3 replicas** defined in the test manifest.

**Verify Resource Calculation:**

Verify that Karmada correctly mapped the CPU and memory requests for the `job-nginx1` component (200m CPU, 100Mi):

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $V_BINDING -n default -o json | jq '.spec.components[] | select(.name=="job-nginx1") | .replicaRequirements.resourceRequest'`{{exec}}

This outputs a JSON object with `"cpu": "200m"` and `"memory": "100Mi"`.

**Verify Scheduling:**

Finally, let's verify which cluster the Volcano Job was scheduled to, and check that the Job actually exists there:

RUN `V_TARGET=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $V_BINDING -n default -o json | jq -r '.spec.clusters[0].name')`{{exec}}

This extracts the scheduled target cluster into a variable.

Verify that the Volcano Job exists on the target cluster:

RUN `kubectl --kubeconfig=$HOME/.kube/config-${V_TARGET#kind-} get jobs.batch.volcano.sh -n default`{{exec}}

This lists the `volcanojob-sample` resource, verifying it exists on the target cluster.
