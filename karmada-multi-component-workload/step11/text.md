Finally, verify that the workload was scheduled and dispatched to exactly **one** member cluster (aggregated placement).

Check Karmada's scheduling decision — you should see a `Scheduled: True` condition and a single cluster entry under `spec.clusters`:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding job-ai-training-job -n default -o yaml`{{exec}}

Check the workload on the target cluster (the cluster shown in `spec.clusters[0].name` above, commonly `kind-member1`):

RUN `kubectl --kubeconfig $HOME/.kube/config-member1 get jobs.batch.volcano.sh`{{exec}}
