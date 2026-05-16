### Prepare Member Clusters

The member clusters (`kind-member1` and `kind-member2`) run on `node01` using [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker). The setup scripts were already copied to `node01` by the background setup.

**Install Kind on the member node:**

RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/installKind.sh"`{{exec}}

This connects to `node01` via SSH and installs Kind, which is required to create local Kubernetes clusters.

**Create two clusters (`member1` and `member2`):**

RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/createCluster.sh"`{{exec}}

This script creates two Kubernetes clusters and copies their kubeconfig files back to the host node.

> This step may take **1–2 minutes** to complete.

**Verify the clusters are accessible:**

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 config get-contexts kind-member1`{{exec}}

This verifies that the `kind-member1` cluster context is correctly configured.

RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 config get-contexts kind-member2`{{exec}}

This verifies that the `kind-member2` cluster context is available.
