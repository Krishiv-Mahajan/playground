#!/bin/bash

# Verify FederatedHPA exists and derived multi-cluster Service is in member1
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get fhpa nginx \
  -o jsonpath='{.spec.scaleTargetRef.name}' | grep -q "nginx" && \
karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc \
  --operation-scope members \
  | grep "derived-nginx-service" \
  | grep -q "kind-member1"

