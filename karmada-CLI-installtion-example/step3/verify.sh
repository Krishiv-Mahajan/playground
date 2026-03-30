#!/bin/bash

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get ns karmada-system
