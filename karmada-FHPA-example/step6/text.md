### Install metrics-server on member clusters

We need to install metrics-server for member clusters to provider the metrics API

RUN `bash ~/installMetricsServer.sh`{{exec}}

It automatically downloads the upstream metrics-server manifest and applies it to both `kind-member1` and `kind-member2`.

**Verify metrics-server availability:**

To confirm the metrics server is running normally, wait a few moments and then check if it can successfully serve pod metrics:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 top pods --all-namespaces`{{exec}}

RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 top pods --all-namespaces`{{exec}}
