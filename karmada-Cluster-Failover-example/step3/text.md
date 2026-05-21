### Initialize Karmada control plane

**Initialize Karmada control plane:**

You need to enable both the `Failover` feature gate and the `eviction` feature to use cluster failover.

When deploying Karmada with `karmadactl init`, append this parameter:

`--karmada-controller-manager-extra-args="--feature-gates=Failover=true,--enable-no-execute-taint-eviction=true"`

You may also manually modify the `karmada-controller-manager` configuration post-installation.

RUN `karmadactl init --karmada-controller-manager-extra-args="--feature-gates=Failover=true,--enable-no-execute-taint-eviction=true"`{{exec}}

This sets up the Karmada control plane on the host cluster, including API server and controllers.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This ensures that the Karmada API server context is available and configured correctly.
