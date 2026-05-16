#!/bin/bash

# Check that nginx deployment is still present and pods are running (may have scaled down)
POD_COUNT=$(karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members -l app=nginx --no-headers 2>/dev/null | wc -l)
[ "$POD_COUNT" -ge 1 ]
