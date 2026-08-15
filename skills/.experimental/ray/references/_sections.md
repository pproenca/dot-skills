# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Ray Train (train)

**Description:** Train V2 has been the default since Ray 2.51, and the vast pre-V2 corpus a model learned from now produces deprecation warnings or silently changed semantics: `ray.air.session.report` gave way to `ray.train.report`, config classes moved from `ray.air` to `ray.train` and lost fields (`sync_config`, `verbose`, `fail_fast`), and `ScalingConfig` grew elastic worker ranges. Training code is the longest-lived code in an ML repo, so V1 idioms written today are tomorrow's migration.

## 2. Ray Serve (serve)

**Description:** Serve is where old code stops loading rather than merely warning: `max_concurrent_queries` is removed (now `max_ongoing_requests`), `RayServeHandle` and `Deployment.deploy()` are gone, and autoscaling fields were renamed. The current surface — `DeploymentHandle`/`DeploymentResponse`, `num_replicas="auto"`, `serve build`/`serve deploy`, per-deployment placement controls — is what a production serving setup is built from.

## 3. Ray Data (data)

**Description:** Ray Data's parameter history whipsawed — `compute=ActorPoolStrategy` was deprecated for `concurrency` mid-2.x, then 2.5x reversed it, so a model can produce either era's idiom and only one is current. Execution is streaming and lazy (`DatasetPipeline`, `window`, `repeat` are removed outright), reads are sized with `override_num_blocks`, and batches are zero-copy read-only views by default — mutating one in place throws.

## 4. Ray Core (core)

**Description:** The Core anti-patterns are the difference between Ray that scales and Ray that is slower than the single-process version: `ray.get` inside loops serializes the cluster, repeated large by-value arguments and captured closures copy gigabytes through task specs, and thousand-microsecond tasks drown in scheduling overhead. The defaults also surprise: retries cover only system failures unless `retry_exceptions` is set, actors never restart unless asked, and the object store takes 30% of node memory with `/dev/shm` implications in containers.

## 5. Ray Tune (tune)

**Description:** The `Tuner` API is the documented surface; `tune.run` still exists but is legacy, and the Tune↔Train boundary was reworked — passing a `TorchTrainer` to `Tuner` is deprecated in favor of a driver function, and the `RunConfig` handed to `Tuner` must come from `ray.tune`, not `ray.train`. These three import-and-shape decisions are exactly where an old-corpus model reaches for the wrong pattern.

## 6. Production & Clusters (prod)

**Description:** Production Ray is KubeRay: the decision of RayCluster vs RayJob vs RayService per workload, the Jobs API instead of drivers on the head node, external Redis for RayService GCS fault tolerance, and baked container images instead of `runtime_env` package lists. None of this is visible from the Python API a model practices on, so its default is a laptop pattern scaled up.
