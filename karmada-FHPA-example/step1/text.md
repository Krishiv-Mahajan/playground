### Environment Overview

The environment consists of two hosts:

1. `controlplane`: The host Kubernetes cluster where Karmada runs. The kubeconfig files for the host cluster are located in the `$HOME/.kube` directory.
2. `node01`: Used to create the two member clusters (`kind-member1` and `kind-member2`).

| HostName | Host IP |
| --- | --- |
| controlplane | 172.30.1.2 |
| node01 | 172.30.2.2 |

Note: The current terminal is on the host `controlplane`.

**Verify the kubeconfig for the host cluster is present:**

RUN `ls $HOME/.kube/`{{exec}}

The `config` file should be listed, confirming the host cluster is reachable.
