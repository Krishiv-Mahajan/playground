### Deploy nginx and propagation policy

1. Apply deployment and service to Karmada control plane:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/nginxDeployment.yaml -f ~/nginx/nginxService.yaml`{{exec}}

2. Apply the propagation policy:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/propagationPolicy.yaml`{{exec}}

3. Check workload status in member clusters:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment --operation-scope members`{{exec}}
RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}
