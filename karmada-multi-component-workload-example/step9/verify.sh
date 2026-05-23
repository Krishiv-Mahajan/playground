#!/bin/bash

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get jobs.batch.volcano.sh volcanojob-sample -n default &> /dev/null && kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy volcano-propagation -n default &> /dev/null
