# Environment Overview

The environment consists of two hosts:

1. `controlplane`: The host Kubernetes cluster where Karmada runs. The kubeconfig files for the host cluster are located in the `$HOME/.kube` directory.
2. `node01`: Used to create member clusters using Kind.

| HostName | Host IP |
| --- | --- |
| controlplane | 172.30.1.2 |
| node01 | 172.30.2.2 |

In this scenario you will:

1. Install `karmadactl` and initialize the Karmada control plane on `controlplane`.
2. Create the Kind-based member clusters on `node01`.
3. Join the member clusters to Karmada.
4. Deploy an nginx workload and verify weighted distribution using `Divided` + `StaticWeight` scheduling.
