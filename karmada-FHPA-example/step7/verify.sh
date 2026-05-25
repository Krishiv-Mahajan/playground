#!/bin/bash

set -e

kubectl --kubeconfig $HOME/.kube/config wait --for=condition=Available deployment/karmada-metrics-adapter -n karmada-system --timeout=5s
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get apiservice v1beta1.metrics.k8s.io
