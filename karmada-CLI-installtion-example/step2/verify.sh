#!/bin/bash

karmadactl version && kubectl --kubeconfig /etc/karmada/karmada-apiserver.config config get-contexts karmada-apiserver
