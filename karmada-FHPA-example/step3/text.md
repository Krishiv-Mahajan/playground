### Deploy FederatedHPA and multi-cluster Service routing

#### 1. Deploy FederatedHPA

Apply the **FederatedHPA** resource in the Karmada control plane. It will autoscale the nginx Deployment across clusters, targeting **10 % average CPU utilisation**, with a minimum of 1 replica and a maximum of 10.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/federatedHPA.yaml`{{exec}}

Check the FederatedHPA status:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa`{{exec}}

You should see `nginx` with `MINPODS=1`, `MAXPODS=10`, and `REPLICAS=1`.

#### 2. Set up multi-cluster Service routing

To allow the load generator in member1 to reach Pods in member2, we need a multi-cluster Service using **ServiceExport** and **ServiceImport**.

Apply the `ServiceExport` (propagated to both clusters):

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/serviceExport.yaml`{{exec}}

Apply the `ServiceImport` (propagated to member1 only):

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/serviceImport.yaml`{{exec}}

Check that the derived multi-cluster Service appears in member1:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

You should see a `derived-nginx-service` entry in **kind-member1**. Note its `CLUSTER-IP` — you will use it in the next step.
