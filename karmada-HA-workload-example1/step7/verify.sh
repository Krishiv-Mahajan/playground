#!/bin/bash

set -e

karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding
kubectl --kubeconfig $HOME/.kube/config-member1 get pods | grep nginx
kubectl --kubeconfig $HOME/.kube/config-member2 get pods | grep nginx
