#!/bin/bash

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment nginx && \
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation
