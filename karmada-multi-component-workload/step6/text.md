Before Karmada can schedule a multi-component AI workload, the control plane needs to know what that workload looks like. We will use a Volcano Job for this tutorial.

Apply the Volcano Job CRD to the Karmada control plane:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/helm/chart/volcano/crd/bases/batch.volcano.sh_jobs.yaml`{{exec}}
