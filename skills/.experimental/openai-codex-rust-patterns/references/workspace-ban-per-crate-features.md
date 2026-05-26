---
title: Avoid per-crate features; use target-cfg or split crates
impact: MEDIUM
impactDescription: prevents combinatorial build matrix explosion across a ~100-crate workspace
tags: workspace, cargo, features, build-matrix
---

## Avoid per-crate features; use target-cfg or split crates

In a workspace this size, Cargo `[features]` create a combinatorial build matrix — each subset is its own compilation unit, CI multiplies, and "it built locally, why did CI fail?" becomes routine. Codex handles optionality two other ways instead: platform variants go in `[target.'cfg(...)'.dependencies]`, and semantic variants become their own crates that compile to nothing on the wrong target. Across ~100 crates there are only two `[features]` sections, both for the same narrow reason a feature is genuinely the right tool: a native C dependency (`v8`) that exposes a compile-time toggle which cannot be expressed as a separate crate or a target-cfg.

**Incorrect (features accrete across crates, the cross product explodes):**

```toml
# core/Cargo.toml
[features]
default = ["linux-sandbox"]
linux-sandbox = ["dep:landlock"]
macos-sandbox = ["dep:sandbox-exec"]
windows-sandbox = ["dep:windows-sys"]
```

**Correct (target-cfg for platforms; separate crates for semantics):**

```toml
# core/Cargo.toml — platform differences live in target tables, not features
[target.x86_64-unknown-linux-musl.dependencies]
openssl-sys = { workspace = true, features = ["vendored"] }

[target.'cfg(unix)'.dependencies]
codex-shell-escalation = { workspace = true }
```

```toml
# code-mode/Cargo.toml — the rare justified feature: a native lib's build-time flag
[features]
sandbox = ["v8/v8_enable_sandbox"]
```

Sandbox backends are *crates* (`codex-linux-sandbox`, `codex-windows-sandbox`, `codex-macos-seatbelt`), each pulled in only under its `[target.'cfg(target_os = "...")']` table, so every build produces the same binary shape regardless of host. Reserve `[features]` for the case codex does — forwarding a flag a third-party native dependency requires — not for first-party optionality.

Reference: `codex-rs/core/Cargo.toml:122`, `codex-rs/code-mode/Cargo.toml:12`.
