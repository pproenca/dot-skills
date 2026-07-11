---
title: Parallel Option fields are a sum type in denial
tags: type, options, sum-types, variants
---

## Parallel Option fields are a sum type in denial

A struct holding one `Option` per possible shape — `api_key: Option<_>, chatgpt_tokens: Option<_>, headers: Option<_>` — encodes "exactly one of these is Some" as a comment instead of a type, so every consumer re-derives the discrimination logic and the all-`None`/two-`Some` states ship as bugs. codex-rs's auth layer is the canonical counter-model: `CodexAuth` is one enum with a variant per mechanism, each carrying that mechanism's payload, so matching is exhaustive and the impossible combinations are unrepresentable. For the two-outcome special case, the same logic applies: `data: Option<T>, error: Option<E>` is a `Result<T, E>`, and "found / not found / failed" is `Result<Option<T>, E>` — the shape codex-rs uses for store lookups like `get_agent_job`.

**Incorrect (one Option per mechanism; "exactly one is Some" lives in prose):**

```rust
struct Auth {
    api_key: Option<String>,
    chatgpt_tokens: Option<IdTokenPair>,
    request_headers: Option<Vec<(String, String)>>,
}

struct IdTokenPair {
    id_token: String,
    refresh_token: String,
}
```

**Correct (a variant per mechanism, each owning its payload — how codex-rs ships `CodexAuth`):**

```rust
enum CodexAuth {
    ApiKey(String),
    Chatgpt(IdTokenPair),
    Headers(Vec<(String, String)>),
}

struct IdTokenPair {
    id_token: String,
    refresh_token: String,
}

fn bearer_token(auth: &CodexAuth) -> Option<&str> {
    match auth {
        CodexAuth::ApiKey(key) => Some(key),
        CodexAuth::Chatgpt(pair) => Some(&pair.id_token),
        CodexAuth::Headers(_) => None,
    }
}
```

Adding a mechanism (codex-rs has seven, from `PersonalAccessToken` to `BedrockApiKey`) now extends the enum and the compiler names every match that must handle it — with parallel Options, the new field is silently `None` everywhere.

Reference: [codex-rs login/src/auth/manager.rs `CodexAuth`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/login/src/auth/manager.rs#L69), [codex-rs state/src/runtime/agent_jobs.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/state/src/runtime/agent_jobs.rs#L101)
