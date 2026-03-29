# What is FederatedHPA?

FederatedHPA (FHPA) is Karmada's multi-cluster autoscaler. It adjusts replicas of a workload distributed across multiple clusters based on observed metrics.

In this scenario, you will:
- bootstrap Karmada and join two member clusters,
- deploy nginx across clusters with a PropagationPolicy,
- create a FederatedHPA that scales by CPU utilization,
- generate traffic and observe scale up and scale down behavior.

Note: this setup can take a few minutes because it creates kind clusters, installs metrics-server in member clusters, and deploys karmada-metrics-adapter.
