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
    wget https://github.com/kubernetes-sigs/kind/releases/download/${kind_version}/kind-linux-amd64
    chmod +x kind-linux-amd64
    sudo mv kind-linux-amd64 /usr/local/bin/kind
EOF
}

function createCluster() {
    cat << EOF > createCluster.sh
    kind create cluster --name=member1 --config=cluster1.yaml
    mv $HOME/.kube/config ~/config-member1
    kind create cluster --name=member2 --config=cluster2.yaml
    mv $HOME/.kube/config config-member2
    KUBECONFIG=~/config-member1:~/config-member2 kubectl config view --merge --flatten >> ${KUBECONFIG_PATH}/config
    # modify ip
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member1
    # set StrictHostKeyChecking to no to avoid prompting, the same below
    scp -o StrictHostKeyChecking=no config-member1 root@${host_cluster_ip}:$HOME/.kube/config-member1
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member2
    scp -o StrictHostKeyChecking=no config-member2 root@${host_cluster_ip}:$HOME/.kube/config-member2
EOF
}

function cluster1Config() {
    touch cluster1.yaml
    cat << EOF > cluster1.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6443
EOF
}

function cluster2Config() {
    touch cluster2.yaml
    cat << EOF > cluster2.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6444
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

function crdPolicy() {
    cat << EOF > crd-policy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: ClusterPropagationPolicy
metadata:
  name: volcano-job-crd-cpp
spec:
  resourceSelectors:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: jobs.batch.volcano.sh
  placement:
    clusterAffinity:
      clusterNames:
        - cluster1
        - cluster2
EOF
}

function volcanoJob() {
    cat << EOF > volcano-job.yaml
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: ai-training-job
  namespace: default
spec:
  minAvailable: 3
  schedulerName: volcano
  tasks:
    - replicas: 1
      name: job-nginx1
      template:
        spec:
          containers:
            - name: container-nginx1
              image: nginx
              resources:
                requests:
                  cpu: "200m"
                  memory: "100Mi"
    - replicas: 2
      name: job-nginx2
      template:
        spec:
          containers:
            - name: container-nginx2
              image: nginx
              resources:
                requests:
                  cpu: "100m"
                  memory: "100Mi"
EOF
}

function jobPolicy() {
    cat << EOF > job-policy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: ai-training-policy
  namespace: default
spec:
  resourceSelectors:
    - apiVersion: batch.volcano.sh/v1alpha1
      kind: Job
      name: ai-training-job
  placement:
    clusterAffinity:
      clusterNames:
        - cluster1
        - cluster2
    replicaScheduling:
      replicaDivisionPreference: Aggregated
      replicaSchedulingType: Divided
EOF
}

kubectl delete node node01
kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# install kind and create member clusters
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

# generate scenario yamls
crdPolicy
volcanoJob
jobPolicy

# clean screen
clear