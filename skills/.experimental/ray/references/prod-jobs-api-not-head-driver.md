---
title: Submit work through the Jobs API, not a driver on the head
tags: prod, jobs-api, ray-client, submission
---

## Submit work through the Jobs API, not a driver on the head

Against a long-lived cluster, the old-corpus patterns — SSH to the head node and run the script there, or connect a local driver via Ray Client (`ray.init("ray://...")`) — couple the workload's lifetime to a shell session or a laptop's network connection. The recommended path is the Jobs API: `ray job submit` packages the entrypoint, runs it on the cluster with its own lifecycle, retriable and observable via `ray job status`/`ray job logs`. Ray Client remains a dev-iteration tool, not a production submission path; on Kubernetes, RayJob wraps this same mechanism in a CRD.

```bash
ray job submit \
  --address http://raycluster-head:8265 \
  --working-dir . \
  --runtime-env-json '{"pip": ["scikit-learn==1.5.2"]}' \
  -- python train.py --epochs 10
```

Reference: [Ray Jobs API overview](https://docs.ray.io/en/latest/cluster/running-applications/job-submission/index.html)
