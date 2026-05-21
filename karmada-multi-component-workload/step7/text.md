Member clusters also need to understand the Volcano Job API before they can accept the workloads. We use a ClusterPropagationPolicy to push the CRD down to the member clusters.

The policy file `crd-policy.yaml` was pre-created for you.

Command to run:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f crd-policy.yaml`{{exec}}
