---
title: Stack HTTP layers as transport, api, and core crates
impact: MEDIUM-HIGH
impactDescription: enables client crate reuse and prevents business logic from pulling in retries
tags: workspace, layering, architecture, crates
---

## Stack HTTP layers as transport, api, and core crates

A single `api_client` crate that pulls in config, auth, and business retry policies is un-reusable — anyone touching retries must recompile your prompt templates. Codex splits "the API client" into three crates with a strict downward dependency: `codex-client` knows only HTTP/SSE/retry primitives (zero Codex awareness), `codex-api` adds request shapes and SSE parsing on top, `codex-core` consumes `codex-api` and owns business logic. `codex-api` depends on `codex-client` and `codex-protocol` — the pure wire crates — but *not* on `codex-core`.

**Incorrect (monolithic client drags business logic everywhere):**

```toml
# codex-api/Cargo.toml
[dependencies]
codex-core = { workspace = true }    # business logic
codex-config = { workspace = true }  # config loading
codex-auth = { workspace = true }    # auth state
reqwest = { workspace = true }
```

**Correct (three layers, strict downward dependencies):**

```text
# codex-client/README.md
Generic transport layer that wraps HTTP requests, retries, and streaming
primitives without any Codex/OpenAI awareness.
- Defines `HttpTransport` and a default `ReqwestTransport`
- Provides retry utilities (`RetryPolicy`, `RetryOn`, `run_with_retry`)
- Consumed by higher-level crates like `codex-api`; it stays neutral on
  endpoints, headers, or API-specific error shapes.
```

```toml
# codex-api/Cargo.toml
[dependencies]
codex-client = { workspace = true }
codex-protocol = { workspace = true }
reqwest = { workspace = true, features = ["json", "stream"] }
eventsource-stream = { workspace = true }
# Notably absent: codex-core, codex-config, codex-auth
```

`codex-client` can be swapped into unrelated projects; `codex-api` can be reused by a different frontend without dragging in `core`'s ~50-dep transitive closure. The layer boundary is enforced by grep — any PR adding `codex-core` to `codex-api/Cargo.toml` is a review objection.

Reference: `codex-rs/codex-client/README.md:1`, `codex-rs/codex-api/Cargo.toml:7`.
