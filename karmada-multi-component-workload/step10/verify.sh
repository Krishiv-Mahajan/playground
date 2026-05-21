#!/bin/bash
# Pass if the ResourceBinding is Scheduled=True
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config \
  get resourcebinding ai-training-job-job -n default \
  -o jsonpath='{.status.conditions[?(@.type=="Scheduled")].status}' | grep -q "True"
