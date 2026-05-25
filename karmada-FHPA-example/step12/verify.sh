#!/bin/bash

set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa
