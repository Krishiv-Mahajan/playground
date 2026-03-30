### Initialize Karmada

Initialize the Karmada control plane.

RUN `karmadactl init`{{exec}}

Verify the Karmada API context is available.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver`{{exec}}
