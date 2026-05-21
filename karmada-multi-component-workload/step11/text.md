Finally, verify that the workload was scheduled and dispatched to a member cluster.

Check Karmada's scheduling decision:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job-job -n default -o wide`{{exec}}

Check the workload on `kind-member1` (the clusters this landed on can be seen in the output above, it may vary):

RUN `kubectl --kubeconfig $HOME/.kube/config-member1 get jobs.batch.volcano.sh`{{exec}}
