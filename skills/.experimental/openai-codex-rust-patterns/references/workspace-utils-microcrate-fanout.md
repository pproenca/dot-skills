---
title: Place shared utilities in single-purpose microcrates under utils/
impact: MEDIUM
impactDescription: enables parallel compilation and minimal dependency graphs per concern
tags: workspace, crate-granularity, compilation, reuse
---

## Place shared utilities in single-purpose microcrates under utils/

"We'll put this in a shared `utils` module" creates a monolithic crate that forces every caller to compile the union of every dependency anyone ever wanted. Codex has a dedicated `utils/` directory that holds 20+ microcrates, each a single concern: `utils/absolute-path`, `utils/elapsed`, `utils/fuzzy-match`, `utils/home-dir`, `utils/readiness`, `utils/stream-parser`. Each is a separate crate so its dependency graph is minimal — e.g. `codex-utils-elapsed` is a duration formatter that does not drag in tokio.

**Incorrect (one monolithic utils crate pulls in everything):**

```toml
# codex-utils/Cargo.toml — the "shared module" crate
[dependencies]
tokio = { workspace = true }       # only needed by pty helper
regex = { workspace = true }       # only needed by fuzzy-match
chrono = { workspace = true }      # only needed by elapsed
ratatui = { workspace = true }     # only needed by sandbox-summary
# Every consumer pays for all of these.
```

**Correct (a microcrate per concern under utils/):**

```toml
# Cargo.toml (workspace root)
[workspace]
members = [
    "utils/absolute-path",
    "utils/cargo-bin",
    "utils/cache",
    "utils/image",
    "utils/json-to-toml",
    "utils/home-dir",
    "utils/pty",
    "utils/readiness",
    "utils/rustls-provider",
    "utils/string",
    "utils/elapsed",
    "utils/sandbox-summary",
    "utils/sleep-inhibitor",
    "utils/fuzzy-match",
    "utils/stream-parser",
    "utils/template",
]

[workspace.dependencies]
codex-utils-absolute-path = { path = "utils/absolute-path" }
codex-utils-elapsed       = { path = "utils/elapsed" }
codex-utils-fuzzy-match   = { path = "utils/fuzzy-match" }
```

The directory structure (`utils/foo`) is distinct from the crate name (`codex-utils-foo`) — the directory namespace keeps the 75-crate `ls` output legible, while the crate-name prefix makes `cargo add codex-utils-*` greppable. `profile.release` uses `lto = "fat"` and `codegen-units = 1` so the crate explosion has zero runtime cost after link-time optimization.

Reference: `codex-rs/Cargo.toml:62`, `codex-rs/Cargo.toml:168`.
