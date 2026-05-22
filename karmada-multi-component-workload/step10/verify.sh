#!/bin/bash
# Verify spec.components is populated (requires MultiplePodTemplatesScheduling=true)
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config \
  get resourcebinding ai-training-job-job -n default \
  -o jsonpath='{.spec.components}' | grep -q "job-nginx1"
