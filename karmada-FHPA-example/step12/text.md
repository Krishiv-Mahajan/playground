### Trigger Load and Observe Autoscaling

Let's put the FederatedHPA to the test!

**Check Baseline Pod Distribution:**

Before generating load, confirm the current state:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

You should see exactly 1 pod running.

**Generate CPU Load:**

To simulate traffic, we will use a lightweight load generation tool called `hey`. Since the member clusters run on a different VM in this environment, we will run the load generator directly inside `kind-member1`. We bypass DNS resolution by targeting the `ClusterIP` of the service directly.

RUN `SVC_IP=$(kubectl --kubeconfig=$HOME/.kube/config-member1 get svc nginx-service -o jsonpath='{.spec.clusterIP}') && kubectl --kubeconfig=$HOME/.kube/config-member1 run load-generator --image=williamyeh/hey --restart=Never -- -c 1000 -z 1m http://$SVC_IP`{{exec}}

This command launches a background pod inside `kind-member1` that continuously hammers the `nginx-service` with HTTP requests for exactly 1 minute.

**Observe the Scale-Up:**

Wait roughly 10–25 seconds after starting the load generator, then check the FederatedHPA status:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

The `REPLICAS` column should have increased above 1.

Check the pod distribution:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

You should now see multiple pods spread across both `kind-member1` and `kind-member2`. Karmada is automatically responding to the increased load!

**Observe the Scale-Down:**

Since we configured the `hey` tool to automatically stop after 1 minute, you don't need to manually terminate the load test.

Wait about a minute for the load to finish and the 10-second stabilization window to expire, then check the pods again:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

The total replica count will have returned to 1 as the FederatedHPA automatically scales back down.
