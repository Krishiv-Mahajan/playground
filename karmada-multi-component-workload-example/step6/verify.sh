#!/bin/bash

# Check CRD propagation
for i in $(seq 1 20); do
  kubectl --kubeconfig=$HOME/.kube/config-member1 get crd flinkdeployments.flink.apache.org &> /dev/null && break
  sleep 3
  if [ "$i" -eq 20 ]; then exit 1; fi
done

# Check Interpreters
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourceinterpretercustomizations flink-component-interpreter &> /dev/null || exit 1

exit 0
