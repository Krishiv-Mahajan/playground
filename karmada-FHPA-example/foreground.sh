#!/usr/bin/env bash

# Source common setup functions and variables from repository root.
COMMON_SETUP="$(dirname "$0")/../common-setup.sh"
if [ ! -f "${COMMON_SETUP}" ]; then
  echo "common-setup.sh not found at ${COMMON_SETUP}; cannot bootstrap environment"
  exit 1
fi
source "${COMMON_SETUP}"

# ---------------------------------------------------------------------------
# Manifest generators
# ---------------------------------------------------------------------------

# nginx Deployment with CPU/memory resource requests (needed for HPA metrics)
function nginxDeployment() {
    cat <<EOF > nginxDeployment.yaml
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
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: 25m
            memory: 64Mi
          limits:
            cpu: 25m
            memory: 64Mi
EOF
}

# ClusterIP Service for nginx
function nginxService() {
    cat <<EOF > nginxService.yaml
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

# PropagationPolicy: Divided/Weighted (1:1) across member1 and member2
function propagationPolicy() {
    cat <<EOF > propagationPolicy.yaml
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

# FederatedHPA – scale on CPU utilisation (target 10 %, min 1, max 10 replicas)
function federatedHPA() {
    cat <<EOF > federatedHPA.yaml
apiVersion: autoscaling.karmada.io/v1alpha1
kind: FederatedHPA
metadata:
  name: nginx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 10
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
    scaleUp:
      stabilizationWindowSeconds: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
EOF
}

# ServiceExport + its PropagationPolicy (both member clusters)
function serviceExport() {
    cat <<EOF > serviceExport.yaml
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceExport
metadata:
  name: nginx-service
---
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: serve-export-policy
spec:
  resourceSelectors:
  - apiVersion: multicluster.x-k8s.io/v1alpha1
    kind: ServiceExport
    name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
      - kind-member1
      - kind-member2
EOF
}

# ServiceImport + its PropagationPolicy (member1 only – load generator lives there)
function serviceImport() {
    cat <<EOF > serviceImport.yaml
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceImport
metadata:
  name: nginx-service
spec:
  type: ClusterSetIP
  ports:
  - port: 80
    protocol: TCP
---
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: serve-import-policy
spec:
  resourceSelectors:
  - apiVersion: multicluster.x-k8s.io/v1alpha1
    kind: ServiceImport
    name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
      - kind-member1
EOF
}

# ---------------------------------------------------------------------------
# Environment bootstrap (re-uses common-setup.sh functions)
# ---------------------------------------------------------------------------

# Setup kubectl on the host node
setupKubectl

# Generate install/cluster scripts and configs, then copy to member node
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

# Generate nginx manifests
mkdir nginx
cd nginx
nginxDeployment
nginxService
propagationPolicy
federatedHPA
serviceExport
serviceImport

# Create kind clusters on the remote member node
createMemberClusters

# Install karmadactl and bootstrap Karmada
installKarmadactl
karmadactl init

if [ ! -f /etc/karmada/karmada-apiserver.config ]; then
  echo "karmadactl init completed without creating /etc/karmada/karmada-apiserver.config"
  exit 1
fi

# Join member clusters
joinMemberClusters

# Install metrics-server in member clusters (required for FHPA resource metrics)
curl -sL https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml \
  | kubectl --kubeconfig "$HOME/.kube/config-member1" apply -f - &
curl -sL https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml \
  | kubectl --kubeconfig "$HOME/.kube/config-member2" apply -f - &
wait

# patch metrics-server to allow insecure TLS (kind clusters use self-signed certs)
for cfg in "$HOME/.kube/config-member1" "$HOME/.kube/config-member2"; do
  kubectl --kubeconfig "$cfg" patch deployment metrics-server \
    -n kube-system \
    --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
done

# Deploy karmada-metrics-adapter in the Karmada control plane
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f \
  https://raw.githubusercontent.com/karmada-io/karmada/master/artifacts/deploy/karmada-metrics-adapter.yaml

# Install hey load-testing tool inside the member1 kind container.
# The kind containers run on the member node, so execute docker there via ssh.
ssh -o StrictHostKeyChecking=no root@${member_cluster_ip} \
  "docker exec member1-control-plane bash -c 'curl -sL https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -o /usr/local/bin/hey && chmod +x /usr/local/bin/hey'" &

# Clear screen after setup completes
wait
clear
