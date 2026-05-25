# What is Karmada?

Karmada (Kubernetes Armada) is a Kubernetes management system that enables you to run your cloud-native applications across multiple Kubernetes clusters and clouds, with no changes to your applications. By speaking Kubernetes-native APIs and providing advanced scheduling capabilities, Karmada enables truly open, multi-cloud Kubernetes.

Karmada aims to provide turnkey automation for multi-cluster application management in multi-cloud and hybrid cloud scenarios, with key features such as centralized multi-cloud management, high availability, failure recovery, and traffic scheduling.

# What is FederatedHPA?

When load increases, FederatedHPA scales up the replicas of the workload if the number of Pods is below the configured maximum. When load decreases, it scales them back down to the configured minimum.

In this scenario, we will create a FederatedHPA targeting CPU utilization, and trigger a CPU load to observe autoscaling across clusters.
