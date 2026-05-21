#!/bin/bash

set -e

pod_counts=$(karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members | awk '
NR > 1 && $1 ~ /^nginx-/ {
	if ($2 == "kind-member1") {
		member1++
	} else if ($2 == "kind-member2") {
		member2++
	}
}
END {
	print member1 + 0, member2 + 0
}')

member1_pod_count=$(echo "$pod_counts" | awk '{print $1}')
member2_pod_count=$(echo "$pod_counts" | awk '{print $2}')

if [ "$member1_pod_count" -eq 3 ] && [ "$member2_pod_count" -eq 0 ]; then
		echo "Pods are scheduled to kind-member1 and absent from kind-member2."
else
		echo "Unexpected pod distribution: kind-member1=$member1_pod_count, kind-member2=$member2_pod_count."
		exit 1
fi
