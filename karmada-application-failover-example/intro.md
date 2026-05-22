# What is Karmada?

Karmada (Kubernetes Armada) is a Kubernetes management system that enables you to run your cloud-native applications across multiple Kubernetes clusters and clouds, with no changes to your applications. By speaking Kubernetes-native APIs and providing advanced scheduling capabilities, Karmada enables truly open, multi-cloud Kubernetes.

# Application-level Failover

In multi-cluster scenarios, user workloads may be deployed in multiple clusters to improve service high availability. While Karmada supports cluster-level failover when detecting a cluster fault, some failures only affect specific applications. For example, a cluster's control plane might be healthy, but an application fails to run due to resource constraints or being recycled.

Karmada provides a means of fault migration from an application perspective. In this scenario, we will first set up Karmada and join member clusters, and then learn how to configure a `PropagationPolicy` for application-level failover.
