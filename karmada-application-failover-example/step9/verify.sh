#!/bin/bash

# Verify there are 2 nginx pods on member2
MEMBER2_COUNT=$(kubectl --kubeconfig ~/.kube/config-member2 --context kind-member2 get pods 2>/dev/null | grep nginx | wc -l)

if [ "$MEMBER2_COUNT" -ne 2 ]; then
  echo "Expected 2 nginx pods on member2, but found $MEMBER2_COUNT"
  exit 1
fi

echo "Failover completed successfully"
