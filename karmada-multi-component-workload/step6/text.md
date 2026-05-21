Before Karmada can schedule a multi-component AI workload, the control plane needs to know what that workload looks like. We will use a Volcano Job for this tutorial.

**Step 1.** Apply the Volcano Job CRD to the Karmada control plane:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/helm/chart/volcano/crd/bases/batch.volcano.sh_jobs.yaml`{{exec}}

**Step 2.** Apply the Resource Interpreter Customization for Volcano Jobs.

This teaches Karmada how to parse the VolcanoJob custom resource and extract the **per-component** replica counts and resource requirements — which is what enables multi-component scheduling. The key Lua function is `GetComponents`, which iterates over `spec.tasks` and reads each task's `replicas` field:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ric-volcano-job.yaml`{{exec}}

Verify it was accepted:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourceinterpretercustomization declarative-configuration-job`{{exec}}
