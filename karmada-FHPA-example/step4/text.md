### Test autoscaling: scale-up and scale-down

#### Scale-up: generate load

1. Get the **CLUSTER-IP** of the `derived-nginx-service` in member1:

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

2. Run `hey` inside the member1 kind container (replace `<CLUSTER-IP>` with the IP from above):

   ```shell
   docker exec member1-control-plane hey -c 1000 -z 1m http://<CLUSTER-IP>
   ```

3. Wait ~15 seconds, then check replicas across clusters:

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

   You should see additional nginx Pods appearing in both **kind-member1** and **kind-member2**.

4. Confirm the FederatedHPA `REPLICAS` count has increased:

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx`{{exec}}

#### Scale-down: load stops

After ~1 minute, `hey` will finish and CPU utilisation will drop below the 10 % threshold.

5. Wait ~30 seconds after load stops, then check Pods again:

   RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

   You should see only **1 Pod** remaining — the minimum replica count defined in the FederatedHPA.

6. Confirm `REPLICAS` is back to 1:

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx`{{exec}}

