#!/bin/bash

KUBECONFIG=/etc/karmada/karmada-apiserver.config

kubectl --kubeconfig "$KUBECONFIG" -n karmada-system get deployment karmada-controller-manager -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "MultiplePodTemplatesScheduling=true" && kubectl --kubeconfig "$KUBECONFIG" -n karmada-system get deployment karmada-scheduler -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "MultiplePodTemplatesScheduling=true" && kubectl --kubeconfig "$KUBECONFIG" -n karmada-system get deployment karmada-scheduler -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "enable-scheduler-estimator=true" && kubectl --kubeconfig "$KUBECONFIG" -n karmada-system get deployment karmada-webhook -o json | jq -r '.spec.template.spec.containers[0].command[]' | grep -q "MultiplePodTemplatesScheduling=true"
