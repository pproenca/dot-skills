---
title: Install ray[llm] and keep the pinned vLLM pairing
tags: serve, install, vllm-version, dependencies
---

## Install ray[llm] and keep the pinned vLLM pairing

`pip install ray vllm` with independently chosen versions is the natural spelling and the top breakage source: Ray's LLM integration tracks vLLM's fast-moving internals, so the `ray[llm]` extra pins an **exact** vLLM release (2.57.0 pins `vllm[audio]==0.25.1`, plus companion pins like `nixl`). Install the extra and let it choose; when a different vLLM version is required, expect to move the Ray version in lockstep rather than mixing pairs — and bake the pair into the serving image so cluster and image can't drift.

```bash
pip install "ray[llm]==2.57.0"   # brings the matched vllm pin with it
```

Reference: [Ray Serve LLM — Quick start](https://docs.ray.io/en/latest/serve/llm/quick-start.html) · [ray 2.57.0 wheel METADATA (llm extra)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/setup.py)
