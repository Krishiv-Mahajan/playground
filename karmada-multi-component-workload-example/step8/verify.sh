#!/bin/bash

set -e

# Wait for ResourceBinding to be created
for i in $(seq 1 20); do
  BINDING_NAME=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding -n default -o json | jq -r '.items[] | select(.spec.resource.kind=="FlinkDeployment") | .metadata.name // empty')
  [ -n "$BINDING_NAME" ] && break
  sleep 3
done
[ -z "$BINDING_NAME" ] && exit 1

for i in $(seq 1 20); do
  TARGET_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $BINDING_NAME -n default -o json | jq -r '.spec.clusters[0].name // empty')
  [ -n "$TARGET_CLUSTER" ] && break
  sleep 3
done
[ -z "$TARGET_CLUSTER" ] && exit 1
kubectl --kubeconfig=$HOME/.kube/config-${TARGET_CLUSTER#kind-} get flinkdeployment -n default &> /dev/null
