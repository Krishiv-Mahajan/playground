#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# variable define
kind_version=v0.17.0
host_cluster_ip=172.30.1.2 #host node where Karmada is located
member_cluster_ip=172.30.2.2
local_ip=127.0.0.1
KUBECONFIG_PATH=${KUBECONFIG_PATH:-"${HOME}/.kube"}

function installKind() {
    cat << EOF > installKind.sh
    set -e
    wget https://github.com/kubernetes-sigs/kind/releases/download/${kind_version}/kind-linux-amd64
    chmod +x kind-linux-amd64
    sudo mv kind-linux-amd64 /usr/local/bin/kind
EOF
}

function createCluster() {
    cat << EOF > createCluster.sh
    set -e
    kind delete cluster --name=member1 || true
    kind create cluster --name=member1 --config=cluster1.yaml
    # Patch kindnet to use less CPU
    kubectl --kubeconfig \$HOME/.kube/config patch daemonset kindnet -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/resources", "value": {"requests": {"cpu": "50m"}, "limits": {"cpu": "200m"}}}]'
    # Patch coredns
    kubectl --kubeconfig \$HOME/.kube/config patch deployment coredns -n kube-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value": "30m"}, {"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value": "100m"}]'
    mv \$HOME/.kube/config ~/config-member1

    kind delete cluster --name=member2 || true
    kind create cluster --name=member2 --config=cluster2.yaml
    kubectl --kubeconfig \$HOME/.kube/config patch daemonset kindnet -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/resources", "value": {"requests": {"cpu": "50m"}, "limits": {"cpu": "200m"}}}]'
    kubectl --kubeconfig \$HOME/.kube/config patch deployment coredns -n kube-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value": "30m"}, {"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value": "100m"}]'
    mv \$HOME/.kube/config config-member2

    # modify ip
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member1
    # set StrictHostKeyChecking to no to avoid prompting, the same below
    scp -o StrictHostKeyChecking=no config-member1 root@${host_cluster_ip}:$HOME/.kube/config-member1
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member2
    scp -o StrictHostKeyChecking=no config-member2 root@${host_cluster_ip}:$HOME/.kube/config-member2
EOF
}

function cluster1Config() {
    cat << EOF > cluster1.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6443
      serviceSubnet: "10.250.0.0/16"
      podSubnet: "10.251.0.0/16"
    nodes:
    - role: control-plane
EOF
}

function cluster2Config() {
    cat << EOF > cluster2.yaml 
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6444
      serviceSubnet: "10.250.0.0/16"
      podSubnet: "10.251.0.0/16"
    nodes:
    - role: control-plane
EOF
}

function installMetrics() {
    cat << 'EOF' > installMetricsServer.sh
# Install metrics-server on member clusters
_tmp=$(mktemp -d)

cleanup() {
  rm -rf "${_tmp}"
}
trap cleanup EXIT

METRICS_SERVER_URL="https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
if command -v curl &>/dev/null && curl -fsSL "${METRICS_SERVER_URL}" -o "${_tmp}/components.yaml"; then
  :
elif command -v wget &>/dev/null && wget -qO "${_tmp}/components.yaml" "${METRICS_SERVER_URL}"; then
  :
else
  echo "ERROR: failed to download metrics-server components.yaml. Please ensure curl or wget is installed and network access is available."
  exit 1
fi

sed -i'' -e 's/args:/args:\n        - --kubelet-insecure-tls=true/' "${_tmp}/components.yaml"

kubectl --kubeconfig=$HOME/.kube/config-member1 apply -f "${_tmp}/components.yaml"
kubectl --kubeconfig=$HOME/.kube/config-member2 apply -f "${_tmp}/components.yaml"
EOF
    chmod +x installMetricsServer.sh

    cat << 'EOF' > installMetricsAdapter.sh
# Install karmada-metrics-adapter on the Karmada control plane
# This bridges metrics from member clusters to the FederatedHPA controller
karmadactl addons enable karmada-metrics-adapter --kubeconfig=$HOME/.kube/config
EOF
    chmod +x installMetricsAdapter.sh


}

function nginxDeployment() {
    cat << EOF > nginxDeployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            cpu: 100m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
EOF
}

function propagationPolicy() {
    cat << EOF > propagationPolicy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
    - apiVersion: v1
      kind: Service
      name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    replicaScheduling:
      replicaDivisionPreference: Weighted
      replicaSchedulingType: Divided
      weightPreference:
        staticWeightList:
          - targetCluster:
              clusterNames:
                - kind-member1
            weight: 1
          - targetCluster:
              clusterNames:
                - kind-member2
            weight: 1
EOF
}

function federatedHPA() {
    cat << EOF > federatedHPA.yaml
apiVersion: autoscaling.karmada.io/v1alpha1
kind: FederatedHPA
metadata:
  name: nginx-fhpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 4
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
    scaleUp:
      stabilizationWindowSeconds: 0
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
EOF
}

function multiClusterService() {
    cat << EOF > multiClusterService.yaml
apiVersion: networking.karmada.io/v1alpha1
kind: MultiClusterService
metadata:
  name: nginx-service
spec:
  types:
    - CrossCluster
  consumerClusters:
    - name: kind-member1
    - name: kind-member2
  providerClusters:
    - name: kind-member1
    - name: kind-member2
EOF
}

function copyConfigFilesToNode() {
    scp -o StrictHostKeyChecking=no \
        installKind.sh \
        createCluster.sh \
        cluster1.yaml \
        cluster2.yaml \
        root@${member_cluster_ip}:~
}

kubectl delete node node01 || true
kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# prepare helper scripts and cluster config files
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

installMetrics

# generate nginx and FHPA config files
mkdir -p ~/fhpa
cd ~/fhpa
nginxDeployment
propagationPolicy
federatedHPA
multiClusterService
cd ~

# clean screen 
clear
