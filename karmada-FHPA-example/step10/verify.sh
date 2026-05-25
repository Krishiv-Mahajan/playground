#!/bin/bash

set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get multiclusterservice nginx-service
