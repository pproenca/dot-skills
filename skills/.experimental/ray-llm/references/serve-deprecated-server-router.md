---
title: Import LLMServer and the ingress from their new modules
tags: serve, llmserver, ingress, deprecation
---

## Import LLMServer and the ingress from their new modules

The 2.44-era beta names — `from ray.serve.llm import LLMServer, LLMRouter` — are deprecated at the top level; customization now imports from submodules: `ray.serve.llm.deployment.LLMServer` and `ray.serve.llm.ingress.OpenAiIngress`. Note the exact casing: the class is `OpenAiIngress` (lowercase "i" in "Ai"), even though the deprecation message itself spells it "OpenAIIngress" — copying the message's spelling produces an `AttributeError`. The OpenAI request/response models live in `ray.serve.llm.openai_api_models`, and custom routers under `ray.serve.llm.request_router`. Most applications never need any of these — `build_openai_app` composes them — so reaching for the classes at all is a signal to check whether a config field already covers the need.

```python
from ray.serve.llm.deployment import LLMServer      # not ray.serve.llm.LLMServer
from ray.serve.llm.ingress import OpenAiIngress     # exact casing: OpenAiIngress
```

Reference: [ray/serve/llm/__init__.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/__init__.py) · [ray/serve/llm/ingress.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/ingress.py)
