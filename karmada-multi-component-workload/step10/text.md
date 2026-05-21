This is the core of the tutorial. Inspect the ResourceBinding that Karmada automatically created when you applied the PropagationPolicy.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job-job -n default -o yaml`{{exec}}

**What to look for in the output:**

**1. `spec.clusters` — single-cluster placement**
The `spreadConstraints` in the policy (MaxGroups=1) forced Karmada to pick exactly **one** cluster for the whole job:
```yaml
spec:
  clusters:
  - name: kind-member1   # all tasks land here together
```

**2. `status.conditions` — scheduling confirmation**
```yaml
status:
  conditions:
  - type: Scheduled
    status: "True"
    message: Binding has been scheduled successfully.
  - type: FullyApplied
    status: "True"
    message: All works have been successfully applied
```

**Note on `spec.components`:** This field — which would show the per-task breakdown (job-nginx1: 1×200m CPU, job-nginx2: 2×100m CPU) — is being added to Karmada's ResourceBinding API in an upcoming release. The `GetComponents` Lua function in our `ResourceInterpreterCustomization` is already written and ready for when that version ships.
