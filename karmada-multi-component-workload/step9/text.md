Karmada needs to know how to distribute this workload. We will use a PropagationPolicy that tells Karmada to calculate the total resources and attempt to keep the components together if possible.

The policy file `job-policy.yaml` was pre-created for you.

Command to run:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f job-policy.yaml`{{exec}}
