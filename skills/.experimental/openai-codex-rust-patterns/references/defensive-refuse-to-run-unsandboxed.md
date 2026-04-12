---
title: Refuse to run when the sandbox cannot enforce the policy
impact: CRITICAL
impactDescription: prevents silent privilege erosion when the sandbox backend lacks the required primitive
tags: defensive, security, sandbox, fail-closed
---

## Refuse to run when the sandbox cannot enforce the policy

Most software follows graceful degradation: if a feature is unsupported, do the best you can. For security boundaries, Codex does the opposite — it returns an error rather than running the command with weaker confinement. Every refusal message repeats the phrase `"refusing to run unsandboxed"` so the string is grepable across the codebase and obviously load-bearing to anyone tempted to soften it into an `Ok(None)` to make a test pass.

**Incorrect (silent privilege erosion):**

```rust
fn prepare_windows_sandbox(roots: &[WritableRoot]) -> Result<SandboxArgs> {
    if windows_cannot_enforce_split_roots(roots) {
        // Couldn't enforce — best effort, run without this restriction
        tracing::warn!("split roots not enforceable, running anyway");
        return Ok(SandboxArgs::default());
    }
    /* ... */
}
```

**Correct (fail closed with a grepable refusal string):**

```rust
// core/src/exec.rs
let Some(legacy_root) = legacy_writable_roots.iter().find(|candidate| {
    normalize_windows_override_path(candidate.root.as_path())
        .is_ok_and(|candidate_path| candidate_path == split_root_path)
}) else {
    return Err(
        "windows unelevated restricted-token sandbox cannot enforce split \
         writable root sets directly; refusing to run unsandboxed"
            .to_string(),
    );
};
```

`refusing to run unsandboxed` appears verbatim in every refusal message across the sandbox backends, turning it into an audit grep. When ops debugs a blocked command, the error says exactly which primitive the backend lacks — not "permission denied" or "sandbox failed" which look like transient errors worth retrying.

Reference: `codex-rs/core/src/exec.rs:1005`, `codex-rs/core/src/exec.rs:1072`.
