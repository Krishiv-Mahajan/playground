### Install karmadactl and initialize Karmada

Install `karmadactl`:

RUN `curl -s https://raw.githubusercontent.com/karmada-io/karmada/master/hack/install-cli.sh | sudo bash`{{exec}}

This downloads and installs the `karmadactl` CLI tool from the official Karmada repository.

Verify installation:

RUN `karmadactl version`{{exec}}

This confirms that `karmadactl` is installed correctly and shows the installed version.

Initialize Karmada control plane:

RUN `karmadactl init`{{exec}}

This sets up the Karmada control plane on the host cluster, including API server and controllers.

Verify initialization:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}

This ensures that the Karmada API server context is available and configured correctly.