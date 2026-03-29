### Background

1. kubeconfig files are available at:

```shell
$HOME/.kube/config
$HOME/.kube/config-member1
$HOME/.kube/config-member2
```

2. Verify both member clusters are joined to Karmada:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters`{{exec}}

You should see `kind-member1` and `kind-member2` in `Ready` status.
