### Join member clusters to the host cluster

1. Join `kind-member1` and `kind-member2` to the host cluster.

   RUN `MEMBER_CLUSTER_NAME=kind-member1`{{exec}}

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member1 --cluster-context=kind-member1`{{exec}}

   RUN `MEMBER_CLUSTER_NAME=kind-member2`{{exec}}

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member2 --cluster-context=kind-member2`{{exec}}
2. Check Karmada resources.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters`{{exec}}
3. The following example output indicates that the member clusters have been joined successfully.

   ![Scan results](../image/success.png)

**Note:** If a join command fails due to a transient issue, rerun that specific join command.
