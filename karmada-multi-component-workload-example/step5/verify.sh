#!/bin/bash

KUBECONFIG=/etc/karmada/karmada-apiserver.config
HOST_KUBECONFIG=${HOST_KUBECONFIG:-$HOME/.kube/config}

kubectl --kubeconfig "$KUBECONFIG" get clusters kind-member1 kind-member2
kubectl --kubeconfig "$HOST_KUBECONFIG" -n karmada-system wait --for=condition=Available deployment/karmada-scheduler-estimator-kind-member1 --timeout=120s
kubectl --kubeconfig "$HOST_KUBECONFIG" -n karmada-system wait --for=condition=Available deployment/karmada-scheduler-estimator-kind-member2 --timeout=120s
