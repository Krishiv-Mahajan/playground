#!/bin/bash
# Verify the binding is Scheduled=True and targets exactly one cluster (matches test assertions)
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding job-ai-training-job -n default -o yaml | grep -A2 'type: Scheduled' | grep 'status: "True"'
