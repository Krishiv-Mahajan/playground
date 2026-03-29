### Test autoscaling

1. Get the `CLUSTER-IP` for the derived nginx service in member clusters:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

2. Run load from member1 kind node (replace `<CLUSTER-IP>`):

```shell
docker exec member1-control-plane hey -c 200 -z 60s http://<CLUSTER-IP>
```

3. While load is running, watch FHPA and pods:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx -w`{{exec}}
RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

4. After load finishes, wait around 30 seconds and check again:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx`{{exec}}
RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx`{{exec}}

Expected: replicas increase during load and scale down after load stops.
