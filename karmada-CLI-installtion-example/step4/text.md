### Join member clusters to Karmada

1. Join `kind-member1`.

   RUN `MEMBER_CLUSTER_NAME=kind-member1`{{exec}}

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member1 --cluster-context=kind-member1`{{exec}}

2. Join `kind-member2`.

   RUN `MEMBER_CLUSTER_NAME=kind-member2`{{exec}}

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member2 --cluster-context=kind-member2`{{exec}}

3. Confirm both clusters are registered.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters`{{exec}}

If a join command fails due to a transient issue, rerun only that failed join command.
