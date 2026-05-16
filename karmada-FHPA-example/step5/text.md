### Join Member Clusters to Karmada

Now that both member clusters are ready and the Karmada control plane is initialized, we join the clusters to Karmada so it can schedule workloads across them.

**Join `kind-member1`:**

RUN `MEMBER_CLUSTER_NAME=kind-member1`{{exec}}

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member1 --cluster-context=kind-member1`{{exec}}

**Join `kind-member2`:**

RUN `MEMBER_CLUSTER_NAME=kind-member2`{{exec}}

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join ${MEMBER_CLUSTER_NAME} --cluster-kubeconfig=$HOME/.kube/config-member2 --cluster-context=kind-member2`{{exec}}

**Verify both clusters are registered with Karmada:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters`{{exec}}

You should see both `kind-member1` and `kind-member2` listed with a `Ready` status.

> **Note:** If a join command fails due to a transient issue, rerun that specific join command.
