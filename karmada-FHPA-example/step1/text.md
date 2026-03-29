### Background：

1. The kubeconfig files for the host cluster and member clusters are located in `$HOME/.kube/`:

   ```shell
   $HOME/.kube/config           # host / Karmada API server
   $HOME/.kube/config-member1
   $HOME/.kube/config-member2
   ```

2. Check that both member clusters have been joined to Karmada:

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get cluster`{{exec}}

   You should see **kind-member1** and **kind-member2** in `Ready` status.

**Note:** The environment initialisation (kind clusters, Karmada bootstrap, metrics-server, karmada-metrics-adapter) may take a few minutes.
