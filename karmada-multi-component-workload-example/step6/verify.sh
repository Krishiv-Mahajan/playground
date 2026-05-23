#!/bin/bash

for i in $(seq 1 20); do
  kubectl --kubeconfig=$HOME/.kube/config-member1 get crd flinkdeployments.flink.apache.org &> /dev/null && exit 0
  sleep 3
done
exit 1
