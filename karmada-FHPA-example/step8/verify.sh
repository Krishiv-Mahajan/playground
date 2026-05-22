#!/bin/bash

set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment nginx
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get service nginx-service
