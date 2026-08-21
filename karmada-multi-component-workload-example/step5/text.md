### Join member clusters to the host cluster

1. Join `kind-member1` and `kind-member2` to the host cluster.

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join kind-member1 --cluster-kubeconfig=$HOME/.kube/config-member1 --cluster-context=kind-member1`{{exec}}

   This joins the `kind-member1` cluster to the Karmada control plane using its kubeconfig file and context.

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config join kind-member2 --cluster-kubeconfig=$HOME/.kube/config-member2 --cluster-context=kind-member2`{{exec}}

   This joins the `kind-member2` cluster to the Karmada control plane using its respective kubeconfig file and context.

2. Check Karmada resources.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters`{{exec}}

   This command lists all the member clusters that have successfully joined the Karmada control plane.

3. Deploy one scheduler estimator for each member cluster. The estimator must be deployed after the member kubeconfigs are available, and the scheduler was initialized with `--enable-scheduler-estimator=true` in the previous step.

   RUN `curl -sSL https://raw.githubusercontent.com/karmada-io/karmada/master/hack/deploy-scheduler-estimator.sh | bash -s -- /etc/karmada/karmada-apiserver.config karmada-apiserver $HOME/.kube/config-member1 kind-member1`{{exec}}

   RUN `curl -sSL https://raw.githubusercontent.com/karmada-io/karmada/master/hack/deploy-scheduler-estimator.sh | bash -s -- /etc/karmada/karmada-apiserver.config karmada-apiserver $HOME/.kube/config-member2 kind-member2`{{exec}}

   These commands create the estimator Deployments and Services in `karmada-system`, allowing the scheduler to query capacity for both member clusters.
4. The following image shows the expected output, indicating that the member clusters have been joined successfully.

![Joined clusters](../image/success.png)

> **Note:** If a join command fails due to a transient issue, rerun that specific join command.
