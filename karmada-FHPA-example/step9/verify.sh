#!/bin/bash

# Check that there is more than 1 nginx pod across member clusters
POD_COUNT=$(karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx --no-headers 2>/dev/null | wc -l)
[ "$POD_COUNT" -gt 1 ]
