Finally, verify that the workload was scheduled and dispatched to a member cluster.

```bash
# Check Karmada's scheduling decision
kubectl get resourcebinding ai-training-job -n default -o wide

# Check the workload on the specific member cluster (assuming it landed on cluster1)
kubectl --kubeconfig ~/.kube/members.config --context cluster1 get jobs.batch.volcano.sh
```
