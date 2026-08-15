---
title: Size the object store and /dev/shm for containers
tags: core, object-store, shm, spilling
---

## Size the object store and /dev/shm for containers

The object store takes **30% of available memory** by default (capped at 200 GB) and lives in shared memory — which containers routinely under-provision: Docker's default `/dev/shm` is 64 MB, and Ray errors at startup when a ≥10 GB store lacks the shm to back it (overridable with `RAY_ALLOW_SLOW_STORAGE=1`, at a large performance cost). Provision `--shm-size` (or K8s `emptyDir` with `medium: Memory`) to match `object_store_memory`. When the store fills, Ray spills to local disk under `/tmp/ray` by default — production nodes need that disk to exist and be fast, or point `object_spilling_directory` somewhere that is. On macOS dev machines the store is capped at 2 GB, so laptop behavior says nothing about production spilling.

```bash
docker run --shm-size=16gb ml-training:latest \
  ray start --head --object-store-memory=$((12 * 1024**3))
```

Reference: [Ray Core — Object spilling](https://docs.ray.io/en/latest/ray-core/objects/object-spilling.html) · [ray/_private/ray_constants.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/_private/ray_constants.py)
