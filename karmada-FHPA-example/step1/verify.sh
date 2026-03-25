#!/bin/bash

# Verify both member clusters are joined and Ready
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get cluster \
  | grep -E "kind-member1|kind-member2" \
  | grep -c "Ready" \
  | grep -q "^2$"
