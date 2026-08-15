---
title: Match the KubeRay CRD to the workload
tags: prod, kuberay, rayjob, rayservice
---

## Match the KubeRay CRD to the workload

The production deployment surface is KubeRay, and the CRD choice is the architecture decision a model skips when it defaults to "start a cluster, run things on it." `RayCluster` is the raw cluster — right for dev and long-lived shared clusters. `RayJob` provisions a cluster per batch job (training runs) and submits the entrypoint; note `shutdownAfterJobFinishes` defaults to **false**, so ephemeral-cluster economics require setting it. `RayService` pairs a cluster with Serve applications and is the only CRD that gives zero-downtime rolling upgrades and health-checked serving. Recurring jobs get `RayCronJob`.

```yaml
apiVersion: ray.io/v1
kind: RayJob
metadata:
  name: churn-train-2026-08
spec:
  shutdownAfterJobFinishes: true    # default false — set it or clusters accumulate
  entrypoint: python train.py
  rayClusterSpec:
    headGroupSpec: { ... }
    workerGroupSpecs: [ ... ]
```

Reference: [KubeRay — Getting started](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started.html) · [RayJob quick start](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html)
