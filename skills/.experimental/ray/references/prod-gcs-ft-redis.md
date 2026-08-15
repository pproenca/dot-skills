---
title: Back RayService GCS with Redis for fault tolerance
tags: prod, gcs, fault-tolerance, redis
---

## Back RayService GCS with Redis for fault tolerance

The head node's GCS holds cluster metadata in memory by default, so a head crash takes the whole cluster — including every Serve replica — down with it, which a model doesn't design around because nothing in the Python API surfaces it. For RayService, enable GCS fault tolerance with an external Redis via the `gcsFaultToleranceOptions` field (KubeRay ≥ 1.3) — the `ray.io/ft-enabled: "true"` annotation is the superseded pre-1.3 spelling, worth recognizing in old manifests but not writing. Ray 2.57 also adds an embedded RocksDB GCS backend (`RAY_gcs_storage=rocksdb`) that removes the Redis dependency, but the documented KubeRay path remains Redis — treat RocksDB as new, not default.

```yaml
apiVersion: ray.io/v1
kind: RayService
metadata:
  name: churn-serve
spec:
  rayClusterConfig:
    gcsFaultToleranceOptions:
      redisAddress: "redis.internal.example.com:6379"
      redisPassword:
        valueFrom:
          secretKeyRef: { name: redis-auth, key: password }
    headGroupSpec: { ... }
```

Reference: [KubeRay — GCS fault tolerance](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/kuberay-gcs-ft.html) · [Ray 2.57.0 release notes](https://github.com/ray-project/ray/releases/tag/ray-2.57.0)
