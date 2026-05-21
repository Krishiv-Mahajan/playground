**Congratulations!**

In this scenario, you learned how Karmada schedules **multi-component workloads** common in AI and big data pipelines:

- Installed the Volcano Job CRD and its **Resource Interpreter Customization** so Karmada can parse nested task components
- Propagated the CRD to member clusters via a `ClusterPropagationPolicy`
- Created a VolcanoJob with two heterogeneous tasks (`job-nginx1` and `job-nginx2`)
- Applied a `PropagationPolicy` with `spreadConstraints` (MaxGroups=1) and `replicaScheduling: Divided/Aggregated` to co-locate all components on one cluster
- Inspected the `ResourceBinding.spec.components` field to confirm Karmada correctly extracted per-component replica counts and resource requirements
- Verified the `Scheduled: True` condition and single-cluster dispatch
