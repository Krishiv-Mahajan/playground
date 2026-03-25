#!/bin/bash

# Verify nginx Pods are running in both member clusters
karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods \
  --operation-scope members -l app=nginx \
  | grep -c "Running" \
  | grep -qE "^[2-9]"
