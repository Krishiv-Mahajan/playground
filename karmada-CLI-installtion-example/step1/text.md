### Prepare member clusters

In intro, the helper scripts were copied to the member node. In this step, you will run them.

1. Install Kind on the member node.

   RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/installKind.sh"`{{exec}}

2. Create `member1` and `member2` clusters and copy kubeconfigs back to the host node.
   This command can take around 1-2 minutes.

   RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/createCluster.sh"`{{exec}}

3. Confirm both member cluster contexts are available.

   RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 config get-contexts kind-member1`{{exec}}

   RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 config get-contexts kind-member2`{{exec}}
