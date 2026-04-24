#!/bin/bash

karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding
karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods
