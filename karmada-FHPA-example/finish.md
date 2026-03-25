**Summary**

In this scenario we used Karmada's **FederatedHPA** to automatically scale an nginx Deployment across two member clusters based on CPU utilisation. We saw how the `karmada-metrics-adapter` aggregates metrics from member clusters, how the FederatedHPA controller reacts to load changes, and how replicas are distributed across clusters by the karmada-scheduler.

**Next steps**

- [FederatedHPA scaling based on custom metrics](https://karmada.io/docs/tutorials/autoscaling-with-custom-metrics)
- [CronFederatedHPA – time-based autoscaling](https://karmada.io/docs/userguide/autoscaling/cronfederatedhpa)
- [FederatedHPA API reference](https://github.com/karmada-io/karmada/blob/master/pkg/apis/autoscaling/v1alpha1/federatedhpa_types.go)
