#!/bin/bash

set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config api-resources | grep karmada
