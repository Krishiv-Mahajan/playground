#!/bin/bash
# Verify the VolcanoJob was dispatched to member1 (single-cluster co-located scheduling)
kubectl --kubeconfig $HOME/.kube/config-member1 get jobs.batch.volcano.sh ai-training-job
