### Initialize Karmada control plane

Multi-component scheduling (`MultiplePodTemplatesScheduling`) is currently an **Alpha** feature in Karmada and is **disabled by default**. We can enable it directly at initialization time using the `--karmada-*-extra-args` flags, which pass additional command-line arguments to the respective control plane components:

RUN `karmadactl init --karmada-controller-manager-extra-args="--feature-gates=MultiplePodTemplatesScheduling=true" --karmada-scheduler-extra-args="--feature-gates=MultiplePodTemplatesScheduling=true" --karmada-scheduler-extra-args="--enable-scheduler-estimator=true" --karmada-webhook-extra-args="--feature-gates=MultiplePodTemplatesScheduling=true"`{{exec}}

This sets up the Karmada control plane on the host cluster with multi-component scheduling enabled on the `karmada-controller-manager`, `karmada-scheduler`, and `karmada-webhook` from the start — no additional patches or restarts needed.

- **karmada-controller-manager**: Parses the workload using the Resource Interpreter framework and populates the `spec.components` array in the `ResourceBinding` to declare the resource requests of all sub-components.
- **karmada-scheduler**: Reads the `spec.components` array and uses the scheduler estimators to calculate the total aggregated resources needed, ensuring the workload is only scheduled to member clusters with sufficient capacity to co-locate all components.
- **karmada-webhook**: Validates the multi-component fields within incoming `ResourceBinding` objects.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This outputs the `karmada-apiserver` context, ensuring that it is available and configured correctly.

Verify that the control plane deployments contain the required feature gates and scheduler estimator flag:

RUN `for component in karmada-controller-manager karmada-scheduler karmada-webhook; do kubectl --kubeconfig /etc/karmada/karmada-apiserver.config -n karmada-system get deployment "$component" -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "MultiplePodTemplatesScheduling=true" || exit 1; done && kubectl --kubeconfig /etc/karmada/karmada-apiserver.config -n karmada-system get deployment karmada-scheduler -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "enable-scheduler-estimator=true"`{{exec}}

This confirms that multi-component scheduling is enabled on the controller manager, scheduler, and webhook, and that the scheduler is configured to use scheduler estimators.
