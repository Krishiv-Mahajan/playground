# Install karmadactl and initialize Karmada

**Install `karmadactl`:**

RUN `curl -s https://raw.githubusercontent.com/karmada-io/karmada/master/hack/install-cli.sh | sudo bash`{{exec}}

This downloads and installs the Karmada CLI tool for managing multi-cluster operations.

**Verify installation:**

RUN `karmadactl version`{{exec}}

This confirms that the `karmadactl` CLI is installed and accessible.

**Initialize Karmada control plane:**

RUN `karmadactl init`{{exec}}

This bootstraps the Karmada control plane on the host cluster.

> **Note:** `karmadactl init` deploys etcd, the Karmada API server, scheduler, and controller manager. This takes approximately **2–3 minutes** — wait for the prompt to return before proceeding.

**Verify initialization:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get cluster`{{exec}}

This confirms the Karmada API server is up and responding. Since no member clusters have been joined yet, it is expected to return **"No resources found"** — clusters will be registered in the next step.
