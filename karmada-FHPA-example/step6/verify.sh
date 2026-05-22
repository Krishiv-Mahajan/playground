#!/bin/bash

set -e

kubectl --kubeconfig=$HOME/.kube/config-member1 -n kube-system get deployment metrics-server
kubectl --kubeconfig=$HOME/.kube/config-member2 -n kube-system get deployment metrics-server
