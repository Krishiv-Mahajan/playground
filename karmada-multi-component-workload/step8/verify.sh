#!/bin/bash
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get jobs.batch.volcano.sh ai-training-job
