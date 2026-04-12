---
title: Avoid per-crate features; use target-cfg or split crates
impact: MEDIUM
impactDescription: prevents combinatorial build matrix explosion across a 75-crate workspace
tags: workspace, cargo, features, build-matrix
---

## Avoid per-crate features; use target-cfg or split crates

In a 75-crate workspace, feature flags create a combinatorial build matrix — each subset is its own compilation unit, CI explodes, and "I built it, why did CI fail?" becomes the default. Codex bans `[features]` outright (the justfile says so) and splits optionality two ways: platform variants go in `[target.'cfg(...)'.dependencies]`, and semantic variants become their own crates. There is not a single `[features]` section in the workspace.

**Incorrect (features accrete across crates, cross product explodes):**

```toml
# core/Cargo.toml
[features]
default = ["linux-sandbox"]
linux-sandbox = ["dep:landlock"]
macos-sandbox = ["dep:sandbox-exec"]
windows-sandbox = ["dep:windows-sys"]
```

**Correct (target-cfg for platforms, separate crates for semantics):**

```just
# justfile — policy is explicit
# Prefer this for routine local runs. Workspace crate features are
# banned, so there should be no need to add `--all-features`.
test:
    cargo nextest run --no-fail-fast
```

```toml
# core/Cargo.toml — zero [features] sections
[target.'cfg(target_os = "macos")'.dependencies]
core-foundation = "0.9"

[target.x86_64-unknown-linux-musl.dependencies]
openssl-sys = { workspace = true, features = ["vendored"] }

[target.'cfg(target_os = "windows")'.dependencies]
windows-sys = { version = "0.52", features = [ /* ... */ ] }

[target.'cfg(unix)'.dependencies]
codex-shell-escalation = { workspace = true }
```

Platform differences are handled entirely by target-cfg tables; feature *presence* is handled by crate splitting (`codex-linux-sandbox`, `codex-windows-sandbox`, `codex-macos-seatbelt`). Each compiles to empty on the wrong OS via `[target.'cfg(target_os = "linux")'.dependencies]`, so building always produces the same binary shape.

Reference: `codex-rs/justfile:49`, `codex-rs/core/Cargo.toml:122`.
