# Autoscaling Across Clusters with FederatedHPA

Karmada's **FederatedHPA** (FederatedHorizontalPodAutoscaler) scales workload replicas up or down across multiple Kubernetes clusters automatically, matching demand by aggregating resource metrics from all member clusters.

When load increases, FederatedHPA distributes additional replicas across clusters. When load decreases, it consolidates replicas — all without any application changes.

## What you will learn

In this scenario, you will:

- Set up a Karmada control plane with two member clusters
- Deploy an nginx workload distributed across `kind-member1` and `kind-member2`
- Configure a **FederatedHPA** to auto-scale based on CPU utilization
- Use a **MultiClusterService** to route traffic across both clusters
- Trigger scale-up with a load test tool (`hey`) and observe cross-cluster autoscaling in action
- Observe the workload automatically scale back down once load subsides

## Architecture

```
┌─────────────────────────────────────────────┐
│            Karmada Control Plane             │
│  ┌─────────────┐   ┌──────────────────────┐ │
│  │ FederatedHPA│   │  MultiClusterService  │ │
│  └──────┬──────┘   └──────────────────────┘ │
└─────────┼───────────────────────────────────┘
          │ scales
    ┌─────┴─────┐
    ▼           ▼
┌────────┐  ┌────────┐
│member1 │  │member2 │
│ nginx  │  │ nginx  │
│  pods  │  │  pods  │
└────────┘  └────────┘
```

> **Note:** The background setup will automatically install `karmadactl`, initialize Karmada, join both member clusters, install `metrics-server` on each member cluster, and enable the `karmada-metrics-adapter`. This may take a few minutes — proceed to Step 1 when the terminal is ready.
