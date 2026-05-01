# Environment overview and prepare member clusters

The environment consists of two hosts:

1. `controlplane`: The host Kubernetes cluster where Karmada runs. The kubeconfig files for the host cluster are located in the `$HOME/.kube` directory.
2. `node01`: Used to create member clusters.

| HostName | Host IP |
| --- | --- |
| controlplane | 172.30.1.2 |
| node01 | 172.30.2.2 |

**Install Kind on member node:**

RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/installKind.sh"`{{exec}}

This installs Kind on the remote node to enable creation of Kubernetes clusters.

**Create member clusters:**

RUN `ssh -o StrictHostKeyChecking=no root@172.30.2.2 "bash ~/createCluster.sh"`{{exec}}

This creates two Kubernetes member clusters (`member1` and `member2`) using Kind.

This step may take 1-2 minutes.
