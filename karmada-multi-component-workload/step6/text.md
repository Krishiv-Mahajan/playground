Before Karmada can schedule a multi-component AI workload, the control plane needs to know what that workload looks like. We will use a Volcano Job for this tutorial.

1. Apply the Volcano Job CRD to the Karmada control plane:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/helm/chart/volcano/crd/bases/batch.volcano.sh_jobs.yaml`{{exec}}

2. Apply Karmada's Resource Interpreter Customization for Volcano Jobs. This explicitly teaches Karmada how to parse the custom resource to extract replicas and compute requirements:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f https://raw.githubusercontent.com/karmada-io/karmada/master/pkg/resourceinterpreter/default/thirdparty/resourcecustomizations/batch.volcano.sh/v1alpha1/Job/customizations.yaml`{{exec}}
