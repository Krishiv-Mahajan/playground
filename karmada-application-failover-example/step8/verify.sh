#!/bin/bash
set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get overridepolicy nginx-override
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation
