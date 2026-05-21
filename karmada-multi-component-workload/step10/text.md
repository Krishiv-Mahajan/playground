This is the core of the tutorial. Inspect the ResourceBinding that Karmada automatically generated. This proves that Karmada successfully parsed the custom resource and extracted the requirements of both components.

Command to run:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job-job -n default -o yaml`{{exec}}

Look for the `spec.components` section in the terminal output. You will see that Karmada has mathematically mapped out the requirements for both `job-nginx1` (1 replica, 200m CPU, 100Mi Memory) and `job-nginx2` (2 replicas, 100m CPU, 100Mi Memory each).
