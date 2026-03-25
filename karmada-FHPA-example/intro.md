# What is FederatedHPA?

FederatedHPA (FHPA) is Karmada's cross-cluster autoscaler. It scales up/down the replicas of a workload (Deployment, StatefulSet, etc.) spread across multiple Kubernetes clusters, automatically matching capacity to demand.

## How it works

1. The **FederatedHPA controller** (running in the Karmada control plane) queries metrics periodically via the `metrics.k8s.io` API.
2. The **karmada-metrics-adapter** intercepts those queries, collects raw metrics from every member cluster where the workload's Pods live, aggregates them, and returns a unified result.
3. The controller calculates the desired replica count and updates the workload scale.
4. The **karmada-scheduler** then redistributes those replicas across the member clusters.

> **Note:** FederatedHPA requires Karmada v1.6.0 or later, `metrics-server` in each member cluster, and `karmada-metrics-adapter` in the control plane.

## What you will learn in this scenario

In this scenario we will:
- Deploy an nginx workload across **kind-member1** and **kind-member2** using a Weighted/Divided `PropagationPolicy`
- Create a `FederatedHPA` that scales on CPU utilisation (target: 10 %)
- Set up multi-cluster Service routing with `ServiceExport` / `ServiceImport`
- Use the `hey` HTTP load generator to drive CPU up and watch FHPA scale replicas out
- Stop the load and watch FHPA scale replicas back down
