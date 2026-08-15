# Ray (open-source)

**Version 0.1.0**  
dot-skills  
August 2026

---

## Abstract

Library-reference skill for production open-source Ray, scoped to classic-ML workloads from training to serving. 26 rules across 6 categories covering where the 2.x line broke with the idioms a model produces by default: Train V2 as the default with ray.train reporting, the Tuner driver-function integration, Ray Data's compute-strategy reversal and streaming execution, Ray Serve's renamed/removed deployment surface, Ray Core anti-patterns and retry defaults, and KubeRay production topology. Pinned to ray 2.57.0; API claims verified against the unpacked wheel and classic-ML examples exercised on a live local runtime.

---

## Table of Contents

1. [Ray Train](references/_sections.md#1-ray-train)
   - 1.1 [Import Train configs from ray.train and scale elastically](references/train-configs-from-ray-train-elastic.md)
   - 1.2 [Report through ray.train, not ray.air session](references/train-report-not-air-session.md)
   - 1.3 [Wrap models and loaders with the prepare utilities](references/train-prepare-model-and-loader.md)
   - 1.4 [Write Train code against V2, the default since 2.51](references/train-v2-default-changed-semantics.md)
2. [Ray Serve](references/_sections.md#2-ray-serve)
   - 2.1 [Autoscale with target_ongoing_requests and factor fields](references/serve-autoscaling-current-fields.md)
   - 2.2 [Configure max_ongoing_requests, not max_concurrent_queries](references/serve-max-ongoing-requests.md)
   - 2.3 [Deploy with serve.run and config files, not Deployment.deploy](references/serve-run-build-deploy.md)
   - 2.4 [Place replicas with deployment options, not manual PGs](references/serve-placement-controls.md)
   - 2.5 [Treat handle calls as DeploymentResponse, not ObjectRef](references/serve-deployment-response-handles.md)
3. [Ray Data](references/_sections.md#3-ray-data)
   - 3.1 [Control read fan-out with override_num_blocks](references/data-override-num-blocks.md)
   - 3.2 [Copy batches before mutating; zero-copy is the default](references/data-zero-copy-read-only-batches.md)
   - 3.3 [Feed training with iter_torch_batches or dataset shards](references/data-iter-torch-batches-not-to-torch.md)
   - 3.4 [Size map_batches pools with compute, not concurrency](references/data-compute-not-concurrency.md)
   - 3.5 [Stream datasets; DatasetPipeline is gone](references/data-streaming-replaced-pipelines.md)
4. [Ray Core](references/_sections.md#4-ray-core)
   - 4.1 [Apply the classic scaling patterns where they hide](references/core-classic-traps-residue.md)
   - 4.2 [Enable retry_exceptions deliberately; retries cover crashes only](references/core-retries-system-failures-only.md)
   - 4.3 [Inspect clusters with ray.util.state](references/core-state-api-not-ray-state.md)
   - 4.4 [Size the object store and /dev/shm for containers](references/core-object-store-sizing.md)
5. [Ray Tune](references/_sections.md#5-ray-tune)
   - 5.1 [Pass ray.tune.RunConfig to Tuner, not ray.train's](references/tune-runconfig-from-ray-tune.md)
   - 5.2 [Reach for Tuner; tune.run is legacy but present](references/tune-tuner-canonical.md)
   - 5.3 [Tune trainers through a driver function](references/tune-driver-function-not-trainer.md)
6. [Production & Clusters](references/_sections.md#6-production-&-clusters)
   - 6.1 [Back RayService GCS with Redis for fault tolerance](references/prod-gcs-ft-redis.md)
   - 6.2 [Bake images for production; runtime_env is for iteration](references/prod-baked-images-not-runtime-env.md)
   - 6.3 [Match the KubeRay CRD to the workload](references/prod-kuberay-crd-choice.md)
   - 6.4 [Submit work through the Jobs API, not a driver on the head](references/prod-jobs-api-not-head-driver.md)
   - 6.5 [Wire Prometheus and Grafana into the dashboard](references/prod-metrics-wiring.md)

---

## References

1. [https://docs.ray.io/en/latest/ray-core/patterns/index.html](https://docs.ray.io/en/latest/ray-core/patterns/index.html)
2. [https://docs.ray.io/en/latest/train/getting-started-pytorch.html](https://docs.ray.io/en/latest/train/getting-started-pytorch.html)
3. [https://docs.ray.io/en/latest/train/user-guides/hyperparameter-optimization.html](https://docs.ray.io/en/latest/train/user-guides/hyperparameter-optimization.html)
4. [https://docs.ray.io/en/latest/train/api/deprecated.html](https://docs.ray.io/en/latest/train/api/deprecated.html)
5. [https://docs.ray.io/en/latest/tune/key-concepts.html](https://docs.ray.io/en/latest/tune/key-concepts.html)
6. [https://docs.ray.io/en/latest/data/data-internals.html](https://docs.ray.io/en/latest/data/data-internals.html)
7. [https://docs.ray.io/en/latest/serve/production-guide/index.html](https://docs.ray.io/en/latest/serve/production-guide/index.html)
8. [https://docs.ray.io/en/latest/serve/production-guide/fault-tolerance.html](https://docs.ray.io/en/latest/serve/production-guide/fault-tolerance.html)
9. [https://docs.ray.io/en/latest/serve/autoscaling-guide.html](https://docs.ray.io/en/latest/serve/autoscaling-guide.html)
10. [https://docs.ray.io/en/latest/cluster/kubernetes/getting-started.html](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started.html)
11. [https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html)
12. [https://docs.ray.io/en/latest/cluster/kubernetes/k8s-ecosystem/prometheus-grafana.html](https://docs.ray.io/en/latest/cluster/kubernetes/k8s-ecosystem/prometheus-grafana.html)
13. [https://docs.ray.io/en/latest/cluster/running-applications/job-submission/index.html](https://docs.ray.io/en/latest/cluster/running-applications/job-submission/index.html)
14. [https://docs.ray.io/en/latest/ray-core/objects/object-spilling.html](https://docs.ray.io/en/latest/ray-core/objects/object-spilling.html)
15. [https://docs.ray.io/en/latest/ray-core/tips-for-first-time.html](https://docs.ray.io/en/latest/ray-core/tips-for-first-time.html)
16. [https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/kuberay-gcs-ft.html](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/kuberay-gcs-ft.html)
17. [https://github.com/ray-project/ray/releases/tag/ray-2.57.0](https://github.com/ray-project/ray/releases/tag/ray-2.57.0)
18. [https://github.com/ray-project/ray/releases/tag/ray-2.51.0](https://github.com/ray-project/ray/releases/tag/ray-2.51.0)
19. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/config.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/config.py)
20. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/train_fn_utils.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/train_fn_utils.py)
21. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/tune.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/tune.py)
22. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/impl/tuner_internal.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/impl/tuner_internal.py)
23. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/dataset.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/dataset.py)
24. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/read_api.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/read_api.py)
25. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/api.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/api.py)
26. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/config.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/config.py)
27. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/handle.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/handle.py)
28. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/runtime_env/runtime_env.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/runtime_env/runtime_env.py)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |