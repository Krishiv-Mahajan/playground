#!/bin/bash

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters kind-member1 && kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get clusters kind-member2
kubectl -n karmada-system rollout status deployment/karmada-scheduler-estimator-kind-member1 && kubectl -n karmada-system rollout status deployment/karmada-scheduler-estimator-kind-member2
