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
    KUBECONFIG=~/config-member1:~/config-member2 kubectl config view --merge --flatten > ${KUBECONFIG_PATH}/config
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
EOF
}

function cluster2Config() {
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

function generateExamples() {
    mkdir -p /root/examples
    
    # CRD Propagation Policy
    cat << 'EOF' > /root/examples/crd-propagation-policy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: ClusterPropagationPolicy
metadata:
  name: crd-propagation
spec:
  resourceSelectors:
    - apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      name: flinkdeployments.flink.apache.org
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
EOF

    # ResourceInterpreterCustomization for FlinkDeployment (componentResource)
    # Applied explicitly so it works even if the installed Karmada version doesn't have this built-in.
    cat << 'EOF' > /root/examples/flink-interpreter.yaml
apiVersion: config.karmada.io/v1alpha1
kind: ResourceInterpreterCustomization
metadata:
  name: flink-component-interpreter
spec:
  target:
    apiVersion: flink.apache.org/v1beta1
    kind: FlinkDeployment
  customizations:
    componentResource:
      luaScript: |
        local kube = require("kube")
        local function get(obj, path)
          local cur = obj
          for i = 1, #path do
            if cur == nil then return nil end
            cur = cur[path[i]]
          end
          return cur
        end
        local function to_num(v, default)
          if v == nil or v == '' then return default end
          local n = tonumber(v)
          if n ~= nil then return n end
          return default
        end
        function GetComponents(observedObj)
          local components = {}
          local jm_replicas = to_num(get(observedObj, {"spec","jobManager","replicas"}), 1)
          local jm_requires = { resourceRequest = {} }
          local jm_cpu    = get(observedObj, {"spec","jobManager","resource","cpu"})
          local jm_memory = get(observedObj, {"spec","jobManager","resource","memory"})
          if jm_cpu ~= nil then jm_requires.resourceRequest.cpu = jm_cpu end
          if jm_memory ~= nil then jm_requires.resourceRequest.memory = jm_memory end
          table.insert(components, { name = "jobmanager", replicas = jm_replicas, replicaRequirements = jm_requires })
          local tm_replicas = to_num(get(observedObj, {"spec","taskManager","replicas"}), nil)
          if tm_replicas == nil then
            local parallelism = to_num(get(observedObj, {"spec","job","parallelism"}), nil)
            local task_slots  = to_num(get(observedObj, {"spec","flinkConfiguration","taskmanager.numberOfTaskSlots"}), nil)
            if parallelism == nil or task_slots == nil or task_slots == 0 then tm_replicas = 1
            else tm_replicas = math.ceil(parallelism / task_slots) end
          end
          local tm_requires = { resourceRequest = {} }
          local tm_cpu    = get(observedObj, {"spec","taskManager","resource","cpu"})
          local tm_memory = get(observedObj, {"spec","taskManager","resource","memory"})
          if tm_cpu ~= nil then tm_requires.resourceRequest.cpu = tm_cpu end
          if tm_memory ~= nil then tm_requires.resourceRequest.memory = tm_memory end
          table.insert(components, { name = "taskmanager", replicas = tm_replicas, replicaRequirements = tm_requires })
          return components
        end
EOF


    # FlinkDeployment CR (matches the upstream test manifest structure)
    cat << 'EOF' > /root/examples/flinkdeployment-cr.yaml
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  name: flinkdeployment-sample
spec:
  flinkConfiguration:
    taskmanager.numberOfTaskSlots: "2"
  flinkVersion: v1_17
  image: flink:1.17
  job:
    args: []
    jarURI: local:///opt/flink/examples/streaming/StateMachineExample.jar
    parallelism: 2
    state: running
    upgradeMode: stateless
  jobManager:
    replicas: 1
    resource:
      cpu: 1
      memory: 100Mi
  serviceAccount: flink
  taskManager:
    resource:
      cpu: 1
      memory: 100Mi
EOF

    # Flink PropagationPolicy
    cat << 'EOF' > /root/examples/flink-policy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: flink-propagation
spec:
  resourceSelectors:
    - apiVersion: flink.apache.org/v1beta1
      kind: FlinkDeployment
      name: flinkdeployment-sample
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1
        minGroups: 1
    replicaScheduling:
      replicaSchedulingType: Divided
      replicaDivisionPreference: Aggregated
EOF


    # Download CRDs
    curl -sSL https://raw.githubusercontent.com/karmada-io/karmada/master/test/e2e/suites/base/manifest/flinkdeployments.flink.apache.org-v1.yaml -o /root/examples/flinkdeployments.flink.apache.org-v1.yaml
}

kubectl delete node node01
kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# generate examples
generateExamples

# install kind and create member clusters
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

# clean screen 
clear
