### Deploy FederatedHPA and multi-cluster service routing

1. Apply FederatedHPA:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/federatedHPA.yaml`{{exec}}

2. Apply ServiceExport and ServiceImport:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/serviceExport.yaml`{{exec}}
RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/serviceImport.yaml`{{exec}}

3. Verify FederatedHPA exists:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx`{{exec}}

4. Verify derived service visibility:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}
