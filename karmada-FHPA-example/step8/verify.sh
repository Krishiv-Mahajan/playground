#!/bin/bash

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get multiclusterservice nginx-service
