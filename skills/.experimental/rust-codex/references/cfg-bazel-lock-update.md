---
title: Run just bazel-lock-update After Dependency Changes
impact: MEDIUM
impactDescription: prevents Bazel CI failure from lockfile drift
tags: cfg, bazel, dependencies, lockfile
---

## Run just bazel-lock-update After Dependency Changes

When you change Rust dependencies (`Cargo.toml` or `Cargo.lock`), run `just bazel-lock-update` from the repo root to refresh `MODULE.bazel.lock`. Then run `just bazel-lock-check` to verify locally before pushing. Include the lockfile update in the same commit as the dependency change.

**Incorrect (dependency change without lockfile update):**

```toml
# codex-rs/core/Cargo.toml
[dependencies]
tokio = { version = "1.38", features = ["full"] }
serde_yaml = "0.9"  # New dependency added
# Forgot: just bazel-lock-update
# CI fails: MODULE.bazel.lock is stale
```

**Correct (lockfile updated alongside dependency change):**

```toml
# codex-rs/core/Cargo.toml
[dependencies]
tokio = { version = "1.38", features = ["full"] }
serde_yaml = "0.9"  # New dependency added
```

```bash
# From repo root:
just bazel-lock-update
just bazel-lock-check
# Commit Cargo.toml, Cargo.lock, and MODULE.bazel.lock together
```
