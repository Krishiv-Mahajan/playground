#!/bin/bash
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job -o yaml | grep "conditionType: FullyApplied"
