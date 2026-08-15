---
title: Expect the full OpenAI surface, validate configs without GPUs
tags: api, endpoints, openai, validation
---

## Expect the full OpenAI surface, validate configs without GPUs

Two scope assumptions to correct. First, the ingress is more than chat: it serves `/v1/chat/completions`, `/v1/completions`, `/v1/models` (+ `/v1/models/{model}`), `/v1/embeddings`, `/v1/audio/transcriptions`, `/v1/score`, and `/tokenize`/`/detokenize`, with streaming — so embedding and reranking workloads belong on the same deployment machinery rather than a hand-built sidecar. Second, the configs are plain pydantic: building and validating them needs no GPU, which makes config linting in CI on CPU runners a gate before anything touches an accelerator. The batch-side configs (`ray.data.llm`) validate with no engine package at all; importing `ray.serve.llm` additionally needs the vLLM — or SGLang — *package* installed (hardware not required), so a serve-config lint job installs the pinned `ray[llm]` but runs on CPU.

```python
from openai import OpenAI

client = OpenAI(base_url="http://serving.internal.example.com:8000/v1", api_key="unused")
embedding = client.embeddings.create(model="qwen-7b-chat", input="churn risk drivers")
stream = client.chat.completions.create(
    model="qwen-7b-chat",
    messages=[{"role": "user", "content": "Summarize this ticket."}],
    stream=True,
)
```

Reference: [Ray Serve LLM — Quick start](https://docs.ray.io/en/latest/serve/llm/quick-start.html) · [ray/llm/_internal/serve/core/ingress/ingress.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/ingress/ingress.py)
