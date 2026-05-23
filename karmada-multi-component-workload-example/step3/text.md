### Initialize Karmada control plane

**Initialize Karmada control plane:**

RUN `karmadactl init`{{exec}}

This sets up the Karmada control plane on the host cluster, including API server and controllers.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This outputs the `karmada-apiserver` context, ensuring that it is available and configured correctly.

### Enable the Multi-Component Scheduling feature gate

Multi-component scheduling (`MultiplePodTemplatesScheduling`) is currently an **Alpha** feature in Karmada and is **disabled by default**. We need to explicitly enable it on the `karmada-controller-manager`, `karmada-scheduler`, and `karmada-webhook` components.

> **Note:** Because these components are running as native Pods on the underlying host cluster, we patch them using the default `kubectl` context, **not** the Karmada API server kubeconfig. We also temporarily change their deployment strategy to `Recreate` to prevent resource deadlocks during the rollout.

Patch the `karmada-controller-manager` deployment to enable the feature gate:

RUN `kubectl -n karmada-system patch deployment karmada-controller-manager --type='json' -p='[{"op":"replace","path":"/spec/strategy","value":{"type":"Recreate"}},{"op":"add","path":"/spec/template/spec/containers/0/command/-","value":"--feature-gates=MultiplePodTemplatesScheduling=true"}]'`{{exec}}

Patch the `karmada-scheduler` deployment to enable the feature gate:

RUN `kubectl -n karmada-system patch deployment karmada-scheduler --type='json' -p='[{"op":"replace","path":"/spec/strategy","value":{"type":"Recreate"}},{"op":"add","path":"/spec/template/spec/containers/0/command/-","value":"--feature-gates=MultiplePodTemplatesScheduling=true"}]'`{{exec}}

Patch the `karmada-webhook` deployment to enable the feature gate:

RUN `kubectl -n karmada-system patch deployment karmada-webhook --type='json' -p='[{"op":"replace","path":"/spec/strategy","value":{"type":"Recreate"}},{"op":"add","path":"/spec/template/spec/containers/0/command/-","value":"--feature-gates=MultiplePodTemplatesScheduling=true"}]'`{{exec}}

