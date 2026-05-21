Before Karmada can schedule a multi-component AI workload, the control plane needs to know what that workload looks like. We will use a Volcano Job for this tutorial.

Apply the Volcano Job CRD to the Karmada control plane:

```bash
kubectl apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/helm/chart/volcano/templates/crd/batch.volcano.sh_jobs.yaml
```
