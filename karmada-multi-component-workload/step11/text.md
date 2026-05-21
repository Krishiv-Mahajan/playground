Finally, verify that the multi-component workload was dispatched to exactly **one** member cluster — proving that Karmada respected the `spreadConstraints: maxGroups=1` and kept all job tasks co-located.

**Step 1.** Check the scheduling decision (note which cluster appears under `spec.clusters`):

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get resourcebinding ai-training-job-job -n default -o wide`{{exec}}

You should see exactly **one** cluster listed. The `SCHEDULED=True` and `FULLYAPPLIED=True` columns confirm the entire workload landed successfully.

**Step 2.** Verify the VolcanoJob is running on `kind-member1` (or whichever cluster was selected):

RUN `kubectl --kubeconfig $HOME/.kube/config-member1 get jobs.batch.volcano.sh`{{exec}}

**What this demonstrates:** Even though the VolcanoJob has two distinct task types with different resource shapes (`job-nginx1` and `job-nginx2`), Karmada treated it as a single atomic unit and placed it entirely on one capable cluster — the fundamental guarantee of multi-component workload scheduling.
