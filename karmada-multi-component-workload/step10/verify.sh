#!/bin/bash
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding job-ai-training-job -n default
