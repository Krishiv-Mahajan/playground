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
        - kind-member1
        - kind-member2
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
        - kind-member1
        - kind-member2
    spreadConstraints:
      - spreadByField: cluster
        maxGroups: 1
        minGroups: 1
    replicaScheduling:
      replicaDivisionPreference: Aggregated
      replicaSchedulingType: Divided
EOF
}

# Generates the ResourceInterpreterCustomization for VolcanoJob.
# Key fix: reads task.replicas (per-task replica count) NOT task.minAvailable
# (which is a top-level Job field, not a per-task field).
function resourceInterpreterCustomization() {
    cat << 'RICEOF' > ric-volcano-job.yaml
apiVersion: config.karmada.io/v1alpha1
kind: ResourceInterpreterCustomization
metadata:
  name: declarative-configuration-job
spec:
  target:
    apiVersion: batch.volcano.sh/v1alpha1
    kind: Job
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
          local tasks = get(observedObj, {"spec", "tasks"})
          if tasks == nil then return components end
          for i, task in ipairs(tasks) do
            -- task.replicas is the per-task replica count field in VolcanoJob
            local replicas = to_num(task.replicas, 1)
            local requires = kube.accuratePodRequirements(task.template)
            local taskName = task.name
            if taskName == nil or taskName == '' then
              taskName = "task-" .. (i - 1)
            end
            table.insert(components, {
              name = taskName,
              replicas = replicas,
              replicaRequirements = requires
            })
          end
          return components
        end
    healthInterpretation:
      luaScript: |
        function InterpretHealth(observedObj)
          if observedObj.status == nil or observedObj.status.state == nil then
            return false
          end
          local phase = observedObj.status.state.phase
          if phase == nil or phase == '' then return false end
          if phase == 'Running' or phase == 'Completed' or phase == 'Pending' then
            return true
          end
          return false
        end
    statusReflection:
      luaScript: |
        function ReflectStatus(observedObj)
          local status = {}
          if observedObj == nil or observedObj.status == nil then return status end
          local s = observedObj.status
          status.minAvailable    = s.minAvailable
          status.pending         = s.pending
          status.running         = s.running
          status.succeeded       = s.succeeded
          status.failed          = s.failed
          status.terminating     = s.terminating
          status.unknown         = s.unknown
          status.version         = s.version
          status.retryCount      = s.retryCount
          status.runningDuration = s.runningDuration
          if s.state ~= nil then status.state = s.state end
          return status
        end
RICEOF
}

function karmadaInitConfig() {
    cat << 'EOF' > karmada-init-config.yaml
apiVersion: config.karmada.io/v1alpha1
kind: KarmadaInitConfig
spec:
  components:
    karmadaControllerManager:
      extraArgs:
        feature-gates: "MultiplePodTemplatesScheduling=true"
    karmadaScheduler:
      extraArgs:
        feature-gates: "MultiplePodTemplatesScheduling=true"
    karmadaWebhook:
      extraArgs:
        feature-gates: "MultiplePodTemplatesScheduling=true"
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
karmadaInitConfig
crdPolicy
volcanoJob
jobPolicy
resourceInterpreterCustomization

# clean screen
clear