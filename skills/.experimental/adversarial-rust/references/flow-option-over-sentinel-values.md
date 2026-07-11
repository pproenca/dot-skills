---
title: Absence needs a type, not a sentinel value
tags: flow, option, sentinels, exit-codes
---

## Absence needs a type, not a sentinel value

C and scripting habits encode "not found" as `-1`, `""`, or a `bool` success flag next to an out-param — values inside the valid domain, so forgetting the check compiles clean and misbehaves quietly. codex-rs returns `Option` from every lookup that can miss (`get_shell`, `get_active_user_layer`, the protocol accessors), and models "found / not found / infrastructure failed" as `Result<Option<T>, E>` — three outcomes, three type-level answers, all forced onto the caller. Its process-exit handling shows the boundary discipline: exit status stays in the typed `std::process::ExitStatus` all the way through, and `.code()` — an `Option<i32>`, `None` meaning killed-by-signal — is collapsed to a conventional `-1` only at the final JSON-reporting edge, where the wire field is itself `Option<i32>`.

**Incorrect (in-domain sentinel; the missed check compiles):**

```rust
fn find_layer_index(layers: &[String], name: &str) -> i64 {
    match layers.iter().position(|l| l == name) {
        Some(i) => i as i64,
        None => -1, // caller may index with this
    }
}
```

**Correct (absence is a type — how codex-rs shapes its lookups):**

```rust
fn find_layer_index(layers: &[String], name: &str) -> Option<usize> {
    layers.iter().position(|l| l == name)
}

#[derive(Debug)]
struct StoreError(String);

// Found / not found / store failure: three outcomes, all in the signature.
fn get_agent_job(job_id: &str) -> Result<Option<String>, StoreError> {
    if job_id.is_empty() {
        return Err(StoreError("empty job id".to_string()));
    }
    Ok(None)
}
```

**When a numeric code IS the domain:** at OS and wire boundaries. Exit codes are genuinely numeric — codex-rs keeps them as `ExitStatus`/`Option<i32>` internally and only assigns conventional numbers (`-1` for signal-killed, a dedicated timeout code) when serializing the outward-facing event. The sentinel smell is a sentinel *replacing* a type interior to your program, not a protocol's numeric vocabulary at its edge.

Reference: [codex-rs core/src/exec.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/exec.rs#L786), [codex-rs config/src/state.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/config/src/state.rs#L316), [codex-rs state/src/runtime/agent_jobs.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/state/src/runtime/agent_jobs.rs#L101)
