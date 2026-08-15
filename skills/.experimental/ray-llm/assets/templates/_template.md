---
title: Rule Title Here
tags: prefix, concept, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. For this skill that usually means naming the stale LLM-on-Ray idiom
the model reproduces (the archived ray-llm repo, a renamed entry point, a
restructured config) and what ray.serve.llm / ray.data.llm on the pinned Ray
version does instead. Verify every API claim against the pinned ray wheel —
this surface churns faster than the rest of Ray, and GPU-dependent behavior
can only be source-verified here, so cite the file that proves it.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "support-chat",
                          "model_source": "Qwen/Qwen2.5-7B-Instruct"},
    accelerator_type="L4",
)
```

Reference: [Source title](https://docs.ray.io/en/latest/serve/llm/quick-start.html)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example. -->
