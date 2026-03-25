### Deploy nginx Deployment, Service, and PropagationPolicy

Apply the nginx Deployment and Service to the Karmada control plane, then propagate them to both member clusters using a **Divided/Weighted** `PropagationPolicy` (equal weight 1:1).

1. Apply the Deployment and Service:

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/nginxDeployment.yaml -f ~/nginx/nginxService.yaml`{{exec}}

2. Apply the PropagationPolicy:

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/propagationPolicy.yaml`{{exec}}

3. Verify the Pods are running in both member clusters:

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

   You should see an nginx Pod in **kind-member1** and **kind-member2**.
