#!/bin/bash

set -e

kubectl --kubeconfig $HOME/.kube/config -n karmada-system get deployment karmada-metrics-adapter
kubectl --kubeconfig $HOME/.kube/config get apiservice v1beta1.custom.metrics.k8s.io
