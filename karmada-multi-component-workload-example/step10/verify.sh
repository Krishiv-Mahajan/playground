#!/bin/bash

set -e

# Wait for ResourceBinding to be created
for i in $(seq 1 20); do
  V_BINDING=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding -n default -o json | jq -r '.items[] | select(.spec.resource.kind=="Job" and .spec.resource.apiVersion=="batch.volcano.sh/v1alpha1") | .metadata.name // empty')
  [ -n "$V_BINDING" ] && break
  sleep 3
done
[ -z "$V_BINDING" ] && exit 1
for i in $(seq 1 20); do
  V_TARGET=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding $V_BINDING -n default -o json | jq -r '.spec.clusters[0].name // empty')
  [ -n "$V_TARGET" ] && break
  sleep 3
done
[ -z "$V_TARGET" ] && exit 1
kubectl --kubeconfig=$HOME/.kube/config-${V_TARGET#kind-} get jobs.batch.volcano.sh -n default &> /dev/null
