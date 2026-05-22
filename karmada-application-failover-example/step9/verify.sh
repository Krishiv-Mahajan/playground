#!/bin/bash

# Verify there are no nginx pods on member1
MEMBER1_COUNT=$(kubectl --kubeconfig ~/.kube/config-member1 --context kind-member1 get pods 2>/dev/null | grep nginx | wc -l)
if [ "$MEMBER1_COUNT" -gt 0 ]; then
  echo "Pods still exist on member1"
  exit 1
fi

# Verify there are nginx pods on member2
MEMBER2_COUNT=$(kubectl --kubeconfig ~/.kube/config-member2 --context kind-member2 get pods 2>/dev/null | grep nginx | wc -l)
if [ "$MEMBER2_COUNT" -eq 0 ]; then
  echo "No pods found on member2"
  exit 1
fi

echo "Failover completed successfully"
