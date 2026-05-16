## Congratulations!

You have successfully completed the **FederatedHPA** tutorial and learned how Karmada automatically scales workloads across multiple clusters.

### What You Accomplished

1. **Set up Karmada infrastructure** — Initialized a Karmada control plane and joined two member clusters
2. **Deployed a distributed workload** — Created an nginx `Deployment` with a `PropagationPolicy` to split replicas across clusters
3. **Configured auto-scaling** — Set up a `FederatedHPA` to scale based on aggregated CPU metrics
4. **Enabled cross-cluster routing** — Created a `MultiClusterService` to distribute traffic across member clusters
5. **Tested scaling behavior** — Triggered scale-up with load testing and observed automatic scale-down when load subsided

### Key Concepts

- **FederatedHPA** aggregates resource metrics from all member clusters and scales workload replicas globally
- **PropagationPolicy** controls how workloads are distributed across clusters
- **MultiClusterService** enables cross-cluster service discovery and traffic distribution
- **karmada-metrics-adapter** bridges the Kubernetes metrics API with multi-cluster metrics collection

### Next Steps

- Explore **memory-based autoscaling** by modifying the FederatedHPA to use `memory` metrics instead of CPU
- Test **custom metrics** autoscaling with the `karmada-metrics-adapter`
- Deploy more complex workloads with **PropagationPolicy** constraints (affinity, replica scheduling)
- Review the official Karmada documentation: https://karmada.io/docs/

### Useful Commands

Monitor your FederatedHPA and workload state:

```bash
# View all FederatedHPA resources
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa

# Check member cluster status
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters

# Get pods across all member clusters
karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members
```

### Troubleshooting

If metrics are not appearing or FederatedHPA is not scaling:

1. Verify `metrics-server` is running on each member cluster
2. Confirm `karmada-metrics-adapter` is enabled in the Karmada control plane
3. Check FederatedHPA events: `kubectl describe fhpa nginx`
4. Review member cluster metrics: `kubectl get hpa --kubeconfig=$HOME/.kube/config-member1`

---

**Thank you for exploring Karmada's FederatedHPA capabilities!**
